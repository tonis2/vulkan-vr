module vr_openxr;
import std::io;
import xr;
import c3w;

const uint EYE_COUNT = 2;
const char[*] APP_NAME = "Vulkan VR Streamer";
const char[*] ENGINE_NAME = "C3 Vulkan Engine";

// OpenXR Context structure
struct OpenXRContext
{
	xr::XrInstance instance;
	xr::XrSession session;
	xr::XrSpace referenceSpace;
	xr::XrSystemId systemId;
	bool sessionRunning;
	xr::XrSessionState sessionState;
	
	// View configuration
	xr::XrViewConfigurationView[EYE_COUNT] viewConfigs;
	uint viewCount;
	
	// Swapchains
	xr::XrSwapchain[EYE_COUNT] swapchains;
	
	// Hand tracking
	xr::XrHandTrackerEXT leftHandTracker;
	xr::XrHandTrackerEXT rightHandTracker;
	bool handTrackingAvailable;
	bool handTrackingEnabled;
}

// Check OpenXR result and log error
fn void check_xr(xr::XrResult result, char* operation)
{
	if (xr::failed(result))
	{
		io::printfn("OpenXR Error during %s: %d", operation, result);
	}
}

// Compare strings
fn bool str_equals(char* a, char* b)
{
	while (*a && *b)
	{
		if (*a != *b) return false;
		a++;
		b++;
	}
	return *a == *b;
}

// Copy string to fixed buffer
fn void copy_str(char* dest, char* src, uint maxLen)
{
	uint i = 0;
	while (*src && i < maxLen - 1)
	{
		dest[i] = *src;
		src++;
		i++;
	}
	dest[i] = '\0';
}

// Initialize OpenXR instance
fn bool init_instance(OpenXRContext* ctx)
{
	io::printn("Initializing OpenXR...");

	// Load OpenXR loader dynamically
	if (!xr::load())
	{
		io::printn("ERROR: Failed to load OpenXR runtime");
		return false;
	}

	// Check available extensions
	uint extCount = 0;
	check_xr(xr::xrEnumerateInstanceExtensionProperties(null, 0, &extCount, null), 
		"enumerate extensions count");
	
	io::printfn("Found %d extensions", extCount);
	
	// Allocate extension properties array on stack
	xr::XrExtensionProperties[64] extProps;
	for (uint i = 0; i < 64; i++)
	{
		extProps[i].type = xr::XR_TYPE_EXTENSION_PROPERTIES;
		extProps[i].next = null;
	}
	
	uint actualCount = extCount < 64 ? extCount : 64;
	check_xr(xr::xrEnumerateInstanceExtensionProperties(null, actualCount, &actualCount, &extProps[0]),
		"enumerate extensions");
	
	// Check for required extensions
	bool vulkanExtFound = false;
	bool handTrackingExtFound = false;
	
	for (uint i = 0; i < actualCount; i++)
	{
		if (str_equals(&extProps[i].extensionName[0], &xr::XR_KHR_VULKAN_ENABLE_EXTENSION_NAME[0]))
		{
			vulkanExtFound = true;
			io::printn("  ✓ Found XR_KHR_vulkan_enable");
		}
		if (str_equals(&extProps[i].extensionName[0], &xr::XR_EXT_HAND_TRACKING_EXTENSION_NAME[0]))
		{
			handTrackingExtFound = true;
			io::printn("  ✓ Found XR_EXT_hand_tracking");
		}
	}
	
	if (!vulkanExtFound)
	{
		io::printn("ERROR: Vulkan extension not available!");
		return false;
	}
	
	ctx.handTrackingAvailable = handTrackingExtFound;
	
	// Prepare extension names using C3 string literals
	// Try enabling BOTH Vulkan extensions
	char*[3] extNames;
	extNames[0] = (char*)"XR_KHR_vulkan_enable";
	extNames[1] = (char*)"XR_KHR_vulkan_enable2";
	uint extNameCount = 2;
	
	io::printfn("Enabling OpenXR extensions:");
	io::printfn("  - XR_KHR_vulkan_enable");
	io::printfn("  - XR_KHR_vulkan_enable2");
	
	// Create application info
	xr::XrApplicationInfo appInfo;
	copy_str(&appInfo.applicationName[0], &APP_NAME[0], 128);
	appInfo.applicationVersion = (xr::XrVersion)xr::make_version(1, 0, 0);
	copy_str(&appInfo.engineName[0], &ENGINE_NAME[0], 128);
	appInfo.engineVersion = (xr::XrVersion)xr::make_version(1, 0, 0);
	appInfo.apiVersion = (xr::XrVersion)xr::make_version(1, 0, 0);
	
	// Create instance
	xr::XrInstanceCreateInfo createInfo;
	createInfo.type = xr::XR_TYPE_INSTANCE_CREATE_INFO;
	createInfo.next = null;
	createInfo.createFlags = 0;
	createInfo.applicationInfo = appInfo;
	createInfo.enabledApiLayerCount = 0;
	createInfo.enabledApiLayerNames = null;
	createInfo.enabledExtensionCount = extNameCount;
	createInfo.enabledExtensionNames = &extNames[0];
	
	xr::XrResult result = xr::xrCreateInstance(&createInfo, &ctx.instance);
	if (xr::failed(result))
	{
		io::printfn("ERROR: xrCreateInstance failed with result %d", result);
		return false;
	}
	
	if (!ctx.instance)
	{
		io::printn("ERROR: Failed to create OpenXR instance (null handle)!");
		return false;
	}

	// Load all instance-level and extension function pointers
	if (!xr::load_instance_fns(ctx.instance))
	{
		io::printn("ERROR: Failed to load OpenXR instance functions");
		return false;
	}

	io::printn("✓ OpenXR instance created successfully");
	
	// Get runtime info
	xr::XrInstanceProperties instProps;
	instProps.type = xr::XR_TYPE_INSTANCE_PROPERTIES;
	instProps.next = null;
	check_xr(xr::xrGetInstanceProperties(ctx.instance, &instProps), "get instance properties");
	
	io::printfn("Runtime: %s", &instProps.runtimeName[0]);
	io::printfn("Version: %d.%d.%d",
		xr::version_major(instProps.runtimeVersion),
		xr::version_minor(instProps.runtimeVersion),
		xr::version_patch(instProps.runtimeVersion));
	
	return true;
}

// Initialize OpenXR system
fn bool init_system(OpenXRContext* ctx)
{
	xr::XrSystemGetInfo systemInfo;
	systemInfo.type = xr::XR_TYPE_SYSTEM_GET_INFO;
	systemInfo.next = null;
	systemInfo.formFactor = xr::XR_FORM_FACTOR_HEAD_MOUNTED_DISPLAY;
	
	check_xr(xr::xrGetSystem(ctx.instance, &systemInfo, &ctx.systemId), "get system");
	
	if (ctx.systemId == (xr::XrSystemId)0)
	{
		io::printn("ERROR: No VR system found! Is WiVRN running?");
		return false;
	}
	
	// Get system properties
	xr::XrSystemProperties systemProps;
	systemProps.type = xr::XR_TYPE_SYSTEM_PROPERTIES;
	systemProps.next = null;
	
	// Check for hand tracking support
	xr::XrSystemHandTrackingPropertiesEXT handTrackingProps;
	handTrackingProps.type = xr::XR_TYPE_SYSTEM_HAND_TRACKING_PROPERTIES_EXT;
	handTrackingProps.next = null;
	
	if (ctx.handTrackingAvailable)
	{
		systemProps.next = &handTrackingProps;
	}
	
	check_xr(xr::xrGetSystemProperties(ctx.instance, ctx.systemId, &systemProps), 
		"get system properties");
	
	io::printfn("System: %s", &systemProps.systemName[0]);
	io::printfn("Max Resolution: %dx%d",
		systemProps.graphicsProperties.maxSwapchainImageWidth,
		systemProps.graphicsProperties.maxSwapchainImageHeight);
	io::printfn("Max Layers: %d", systemProps.graphicsProperties.maxLayerCount);
	io::printfn("Orientation Tracking: %s", 
		systemProps.trackingProperties.orientationTracking ? "yes" : "no");
	io::printfn("Position Tracking: %s",
		systemProps.trackingProperties.positionTracking ? "yes" : "no");
	
	if (ctx.handTrackingAvailable && handTrackingProps.supportsHandTracking)
	{
		io::printn("Hand Tracking: supported");
		ctx.handTrackingEnabled = true;
	}
	else
	{
		io::printn("Hand Tracking: not available");
		ctx.handTrackingEnabled = false;
	}
	
	return true;
}

// Get view configuration
fn bool get_view_configuration(OpenXRContext* ctx)
{
	// Get view configuration views
	uint viewCount = 0;
	check_xr(xr::xrEnumerateViewConfigurationViews(ctx.instance, ctx.systemId,
		xr::XR_VIEW_CONFIGURATION_TYPE_PRIMARY_STEREO, 0, &viewCount, null),
		"enumerate view config views count");
	
	if (viewCount != EYE_COUNT)
	{
		io::printfn("ERROR: Expected %d views, got %d", EYE_COUNT, viewCount);
		return false;
	}
	
	ctx.viewCount = viewCount;
	
	for (uint i = 0; i < EYE_COUNT; i++)
	{
		ctx.viewConfigs[i].type = xr::XR_TYPE_VIEW_CONFIGURATION_VIEW;
		ctx.viewConfigs[i].next = null;
	}
	
	check_xr(xr::xrEnumerateViewConfigurationViews(ctx.instance, ctx.systemId,
		xr::XR_VIEW_CONFIGURATION_TYPE_PRIMARY_STEREO, EYE_COUNT, &viewCount, &ctx.viewConfigs[0]),
		"enumerate view config views");
	
	io::printn("View Configuration:");
	for (uint i = 0; i < EYE_COUNT; i++)
	{
		io::printfn("  Eye %d: recommended %dx%d, max %dx%d",
			i,
			ctx.viewConfigs[i].recommendedImageRectWidth,
			ctx.viewConfigs[i].recommendedImageRectHeight,
			ctx.viewConfigs[i].maxImageRectWidth,
			ctx.viewConfigs[i].maxImageRectHeight);
	}
	
	return true;
}

// Create reference space
fn bool create_reference_space(OpenXRContext* ctx)
{
	xr::XrReferenceSpaceCreateInfo refSpaceCreateInfo;
	refSpaceCreateInfo.type = xr::XR_TYPE_REFERENCE_SPACE_CREATE_INFO;
	refSpaceCreateInfo.next = null;
	refSpaceCreateInfo.referenceSpaceType = xr::XR_REFERENCE_SPACE_TYPE_LOCAL_FLOOR;
	refSpaceCreateInfo.poseInReferenceSpace.orientation.x = 0;
	refSpaceCreateInfo.poseInReferenceSpace.orientation.y = 0;
	refSpaceCreateInfo.poseInReferenceSpace.orientation.z = 0;
	refSpaceCreateInfo.poseInReferenceSpace.orientation.w = 1;
	refSpaceCreateInfo.poseInReferenceSpace.position.x = 0;
	refSpaceCreateInfo.poseInReferenceSpace.position.y = 0;
	refSpaceCreateInfo.poseInReferenceSpace.position.z = 0;
	
	check_xr(xr::xrCreateReferenceSpace(ctx.session, &refSpaceCreateInfo, &ctx.referenceSpace),
		"create reference space");
	
	if (!ctx.referenceSpace)
	{
		io::printn("ERROR: Failed to create reference space!");
		return false;
	}
	
	return true;
}

// Create hand trackers
fn bool create_hand_trackers(OpenXRContext* ctx)
{
	if (!ctx.handTrackingEnabled) return true;

	if (xr::xrCreateHandTrackerEXT == null)
	{
		io::printn("Hand tracking enabled but extension functions not loaded");
		ctx.handTrackingEnabled = false;
		return true;
	}

	// Create left hand tracker
	xr::XrHandTrackerCreateInfoEXT leftInfo;
	leftInfo.type = xr::XR_TYPE_HAND_TRACKER_CREATE_INFO_EXT;
	leftInfo.next = null;
	leftInfo.hand = xr::XR_HAND_LEFT_EXT;
	leftInfo.handJointSet = xr::XR_HAND_JOINT_SET_DEFAULT_EXT;

	xr::XrResult result = xr::xrCreateHandTrackerEXT(ctx.session, &leftInfo, &ctx.leftHandTracker);
	if (xr::failed(result))
	{
		io::printfn("WARNING: Failed to create left hand tracker: %d", result);
		ctx.handTrackingEnabled = false;
		return true;
	}

	// Create right hand tracker
	xr::XrHandTrackerCreateInfoEXT rightInfo;
	rightInfo.type = xr::XR_TYPE_HAND_TRACKER_CREATE_INFO_EXT;
	rightInfo.next = null;
	rightInfo.hand = xr::XR_HAND_RIGHT_EXT;
	rightInfo.handJointSet = xr::XR_HAND_JOINT_SET_DEFAULT_EXT;

	result = xr::xrCreateHandTrackerEXT(ctx.session, &rightInfo, &ctx.rightHandTracker);
	if (xr::failed(result))
	{
		io::printfn("WARNING: Failed to create right hand tracker: %d", result);
		// Left tracker already created, destroy it
		xr::xrDestroyHandTrackerEXT(ctx.leftHandTracker);
		ctx.leftHandTracker = null;
		ctx.handTrackingEnabled = false;
		return true;
	}

	io::printn("✓ Hand trackers created");
	return true;
}

// Poll OpenXR events
fn bool poll_events(OpenXRContext* ctx)
{
	xr::XrEventDataBuffer event;
	event.type = xr::XR_TYPE_EVENT_DATA_BUFFER;
	event.next = null;
	
	while (xr::xrPollEvent(ctx.instance, &event) == xr::XR_SUCCESS)
	{
		switch (event.type)
		{
			case xr::XR_TYPE_EVENT_DATA_SESSION_STATE_CHANGED:
			{
				xr::XrEventDataSessionStateChanged* stateChanged = 
					(xr::XrEventDataSessionStateChanged*)&event;
				ctx.sessionState = stateChanged.state;
				
				switch (ctx.sessionState)
				{
					case xr::XR_SESSION_STATE_READY:
					{
						xr::XrSessionBeginInfo beginInfo;
						beginInfo.type = xr::XR_TYPE_SESSION_BEGIN_INFO;
						beginInfo.next = null;
						beginInfo.primaryViewConfigurationType = 
							xr::XR_VIEW_CONFIGURATION_TYPE_PRIMARY_STEREO;
						
						check_xr(xr::xrBeginSession(ctx.session, &beginInfo), "begin session");
						ctx.sessionRunning = true;
						io::printn("Session started");
					}
					case xr::XR_SESSION_STATE_STOPPING:
					{
						check_xr(xr::xrEndSession(ctx.session), "end session");
						ctx.sessionRunning = false;
						io::printn("Session stopped");
					}
					case xr::XR_SESSION_STATE_EXITING:
					case xr::XR_SESSION_STATE_LOSS_PENDING:
					{
						io::printn("Session exiting or lost");
						return false;
					}
					default:
					{
						// No action needed
					}
				}
			}
			default:
			{
				// Unhandled event
			}
		}
	}
	
	return true;
}

// Create OpenXR session with Vulkan graphics binding
fn bool create_vulkan_session(OpenXRContext* ctx, void* vulkanInstance, void* physicalDevice, void* device, uint queueFamilyIndex, uint queueIndex)
{
	io::printn("Creating OpenXR session with Vulkan graphics binding...");

	// Call xrGetVulkanGraphicsRequirementsKHR (required before session creation)
	if (xr::xrGetVulkanGraphicsRequirementsKHR != null)
	{
		xr::XrGraphicsRequirementsVulkanKHR graphicsReqs;
		graphicsReqs.type = xr::XR_TYPE_GRAPHICS_REQUIREMENTS_VULKAN_KHR;
		graphicsReqs.next = null;
		check_xr(xr::xrGetVulkanGraphicsRequirementsKHR(ctx.instance, ctx.systemId, &graphicsReqs),
			"get Vulkan graphics requirements");
		io::printfn("Vulkan API version: min %d.%d.%d, max %d.%d.%d",
			xr::version_major(graphicsReqs.minApiVersionSupported),
			xr::version_minor(graphicsReqs.minApiVersionSupported),
			xr::version_patch(graphicsReqs.minApiVersionSupported),
			xr::version_major(graphicsReqs.maxApiVersionSupported),
			xr::version_minor(graphicsReqs.maxApiVersionSupported),
			xr::version_patch(graphicsReqs.maxApiVersionSupported));
	}

	// Create graphics binding
	xr::XrGraphicsBindingVulkanKHR graphicsBinding;
	graphicsBinding.type = xr::XR_TYPE_GRAPHICS_BINDING_VULKAN_KHR;
	graphicsBinding.next = null;
	graphicsBinding.instance = vulkanInstance;
	graphicsBinding.physicalDevice = physicalDevice;
	graphicsBinding.device = device;
	graphicsBinding.queueFamilyIndex = queueFamilyIndex;
	graphicsBinding.queueIndex = queueIndex;
	
	// Create session
	xr::XrSessionCreateInfo sessionCreateInfo;
	sessionCreateInfo.type = xr::XR_TYPE_SESSION_CREATE_INFO;
	sessionCreateInfo.next = &graphicsBinding;
	sessionCreateInfo.createFlags = 0;
	sessionCreateInfo.systemId = ctx.systemId;
	
	check_xr(xr::xrCreateSession(ctx.instance, &sessionCreateInfo, &ctx.session), "create session");
	
	if (!ctx.session)
	{
		io::printn("ERROR: Failed to create OpenXR session!");
		return false;
	}
	
	io::printn("✓ OpenXR session created with Vulkan binding");
	
	// Create reference space
	if (!create_reference_space(ctx))
	{
		xr::xrDestroySession(ctx.session);
		ctx.session = null;
		return false;
	}
	
	io::printn("✓ Reference space created");
	
	// Create hand trackers if available
	if (!create_hand_trackers(ctx))
	{
		io::printn("WARNING: Failed to create hand trackers");
	}
	
	return true;
}

// Create stereo swapchains
fn bool create_stereo_swapchains(OpenXRContext* ctx)
{
	io::printn("Creating stereo swapchains...");
	
	for (uint eye = 0; eye < EYE_COUNT; eye++)
	{
		uint width = ctx.viewConfigs[eye].recommendedImageRectWidth;
		uint height = ctx.viewConfigs[eye].recommendedImageRectHeight;
		
		io::printfn("  Eye %d: %dx%d", eye, width, height);
		
		xr::XrSwapchainCreateInfo swapchainCreateInfo;
		swapchainCreateInfo.type = xr::XR_TYPE_SWAPCHAIN_CREATE_INFO;
		swapchainCreateInfo.next = null;
		swapchainCreateInfo.createFlags = 0;
		swapchainCreateInfo.usageFlags = xr::XR_SWAPCHAIN_USAGE_COLOR_ATTACHMENT_BIT;
		swapchainCreateInfo.format = 37; // VK_FORMAT_B8G8R8A8_SRGB
		swapchainCreateInfo.sampleCount = 1;
		swapchainCreateInfo.width = width;
		swapchainCreateInfo.height = height;
		swapchainCreateInfo.faceCount = 1;
		swapchainCreateInfo.arraySize = 1;
		swapchainCreateInfo.mipCount = 1;
		
		check_xr(xr::xrCreateSwapchain(ctx.session, &swapchainCreateInfo, &ctx.swapchains[eye]),
			"create swapchain");
		
		if (!ctx.swapchains[eye])
		{
			io::printfn("ERROR: Failed to create swapchain for eye %d!", eye);
			
			// Cleanup already created swapchains
			for (uint j = 0; j < eye; j++)
			{
				if (ctx.swapchains[j])
				{
					xr::xrDestroySwapchain(ctx.swapchains[j]);
					ctx.swapchains[j] = null;
				}
			}
			return false;
		}
	}
	
	io::printn("✓ Stereo swapchains created");
	return true;
}

// Cleanup OpenXR
fn void cleanup(OpenXRContext* ctx)
{
	io::printn("Cleaning up OpenXR...");

	if (ctx.handTrackingEnabled && xr::xrDestroyHandTrackerEXT != null)
	{
		if (ctx.leftHandTracker) xr::xrDestroyHandTrackerEXT(ctx.leftHandTracker);
		if (ctx.rightHandTracker) xr::xrDestroyHandTrackerEXT(ctx.rightHandTracker);
	}

	for (uint i = 0; i < EYE_COUNT; i++)
	{
		if (ctx.swapchains[i]) xr::xrDestroySwapchain(ctx.swapchains[i]);
	}

	if (ctx.referenceSpace) xr::xrDestroySpace(ctx.referenceSpace);
	if (ctx.session) xr::xrDestroySession(ctx.session);
	if (ctx.instance) xr::xrDestroyInstance(ctx.instance);

	xr::unload();

	io::printn("OpenXR cleanup complete");
}
