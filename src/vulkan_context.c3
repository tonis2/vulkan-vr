module vr_vulkan;
import std::io;
import vk, xr;
import vr_openxr;

struct VulkanContext
{
	// Vulkan handles
	vk::Instance instance;
	vk::PhysicalDevice physicalDevice;
	vk::Device device;
	vk::Queue graphicsQueue;
	uint graphicsQueueFamilyIndex;

	// OpenXR integration
	bool xrReady;
}

// Parse a space-separated string of extension names in-place.
// Replaces spaces with '\0' and fills an array of pointers to each name.
// Returns the number of extensions found.
fn uint parse_extensions(char* buffer, char*[] outPtrs)
{
	uint count = 0;
	uint max = (uint)outPtrs.len;
	bool inName = false;
	char* start = null;

	for (char* p = buffer; *p != 0; p++)
	{
		if (*p == ' ')
		{
			if (inName)
			{
				*p = 0;
				if (count < max)
				{
					outPtrs[count] = start;
					count++;
				}
				inName = false;
			}
		}
		else
		{
			if (!inName)
			{
				start = p;
				inName = true;
			}
		}
	}
	// Last name (no trailing space)
	if (inName && count < max)
	{
		outPtrs[count] = start;
		count++;
	}
	return count;
}

// Initialize Vulkan with OpenXR-required extensions
fn bool init_vulkan(vr_openxr::OpenXRContext* xrCtx, VulkanContext* vkCtx)
{
	io::printn("Initializing Vulkan...");

	// --- Query required Vulkan instance extensions from OpenXR ---
	char*[32] instanceExtPtrs;
	uint instanceExtCount = 0;

	if (xr::getVulkanInstanceExtensionsKHR != null)
	{
		uint bufSize = 0;
		if (catch err = xr::getVulkanInstanceExtensionsKHR(
			xrCtx.instance, xrCtx.systemId, 0, &bufSize, null).ok())
		{
			io::printn("WARNING: Failed to query Vulkan instance extensions from OpenXR");
		}
		else if (bufSize > 0)
		{
			char[4096] extBuf;
			if (bufSize > 4096) { bufSize = 4096; }
			if (catch e = xr::getVulkanInstanceExtensionsKHR(
				xrCtx.instance, xrCtx.systemId, bufSize, &bufSize, &extBuf[0]).ok())
			{
				io::printn("WARNING: Failed to get Vulkan instance extensions from OpenXR");
			}
			else
			{
				instanceExtCount = parse_extensions(&extBuf[0], &instanceExtPtrs);
				io::printfn("OpenXR requires %d Vulkan instance extensions:", instanceExtCount);
				for (uint i = 0; i < instanceExtCount; i++)
				{
					io::printfn("  - %s", instanceExtPtrs[i]);
				}
			}
		}
	}

	// Vulkan application info
	vk::ApplicationInfo appInfo;
	appInfo.sType = vk::STRUCTURE_TYPE_APPLICATION_INFO;
	appInfo.pNext = null;
	appInfo.pApplicationName = "Vulkan VR Streamer";
	appInfo.applicationVersion = ((1 << 22) | (0 << 12) | 0);
	appInfo.pEngineName = "C3 Vulkan Engine";
	appInfo.engineVersion = ((1 << 22) | (0 << 12) | 0);
	appInfo.apiVersion = ((1 << 22) | (2 << 12) | 0);

	// Vulkan instance create info with XR-required extensions
	vk::InstanceCreateInfo createInfo;
	createInfo.sType = vk::STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
	createInfo.pNext = null;
	createInfo.flags = 0;
	createInfo.pApplicationInfo = &appInfo;
	createInfo.enabledLayerCount = 0;
	createInfo.ppEnabledLayerNames = null;
	createInfo.enabledExtensionCount = instanceExtCount;
	createInfo.ppEnabledExtensionNames = (char*)&instanceExtPtrs[0];

	vk::createInstance(&createInfo, null, &vkCtx.instance)!!;
	io::printn("Vulkan instance created");

	// --- Call xrGetVulkanGraphicsRequirementsKHR (required before session creation) ---
	if (xr::getVulkanGraphicsRequirementsKHR != null)
	{
		xr::XrGraphicsRequirementsVulkanKHR graphicsReqs;
		graphicsReqs.type = xr::XR_TYPE_GRAPHICS_REQUIREMENTS_VULKAN_KHR;
		graphicsReqs.next = null;
		if (catch err = xr::getVulkanGraphicsRequirementsKHR(
			xrCtx.instance, xrCtx.systemId, &graphicsReqs).ok())
		{
			io::printn("WARNING: getVulkanGraphicsRequirementsKHR failed");
		}
		else
		{
			io::printfn("Vulkan API version: min %d.%d.%d, max %d.%d.%d",
				xr::version_major(graphicsReqs.minApiVersionSupported),
				xr::version_minor(graphicsReqs.minApiVersionSupported),
				xr::version_patch(graphicsReqs.minApiVersionSupported),
				xr::version_major(graphicsReqs.maxApiVersionSupported),
				xr::version_minor(graphicsReqs.maxApiVersionSupported),
				xr::version_patch(graphicsReqs.maxApiVersionSupported));
		}
	}

	// --- Get physical device from OpenXR ---
	bool gotXrPhysDevice = false;
	if (xr::getVulkanGraphicsDeviceKHR != null)
	{
		vk::PhysicalDevice xrPhysDev;
		if (catch err = xr::getVulkanGraphicsDeviceKHR(
			xrCtx.instance, xrCtx.systemId, (void*)vkCtx.instance, &xrPhysDev).ok())
		{
			io::printn("WARNING: getVulkanGraphicsDeviceKHR failed, falling back");
		}
		else if (xrPhysDev != null)
		{
			vkCtx.physicalDevice = xrPhysDev;
			gotXrPhysDevice = true;
			io::printn("Physical device selected by OpenXR");
		}
	}

	if (!gotXrPhysDevice)
	{
		// Fallback: enumerate and pick first device
		vk::PhysicalDevice[8] physicalDevices;
		uint deviceCount = 8;
		vk::enumeratePhysicalDevices(vkCtx.instance, &deviceCount, &physicalDevices[0])!!;

		if (deviceCount == 0)
		{
			io::printn("ERROR: No Vulkan physical devices found!");
			vk::destroyInstance(vkCtx.instance, null);
			return false;
		}

		vkCtx.physicalDevice = physicalDevices[0];
		io::printfn("Physical device selected (%d available)", deviceCount);
	}

	// Find graphics queue family
	vk::QueueFamilyProperties[32] queueFamilies;
	uint queueFamilyCount = 32;
	vk::getPhysicalDeviceQueueFamilyProperties(
		vkCtx.physicalDevice, &queueFamilyCount, &queueFamilies[0]);

	vkCtx.graphicsQueueFamilyIndex = 0xFFFFFFFF;
	for (uint i = 0; i < queueFamilyCount; i++)
	{
		if (queueFamilies[i].queueFlags & vk::QUEUE_GRAPHICS_BIT)
		{
			vkCtx.graphicsQueueFamilyIndex = i;
			break;
		}
	}

	if (vkCtx.graphicsQueueFamilyIndex == 0xFFFFFFFF)
	{
		io::printn("ERROR: No graphics queue family found!");
		vk::destroyInstance(vkCtx.instance, null);
		return false;
	}

	io::printfn("Graphics queue family: %d", vkCtx.graphicsQueueFamilyIndex);

	// --- Query required Vulkan device extensions from OpenXR ---
	char*[32] deviceExtPtrs;
	uint deviceExtCount = 0;

	if (xr::getVulkanDeviceExtensionsKHR != null)
	{
		uint bufSize = 0;
		if (catch err = xr::getVulkanDeviceExtensionsKHR(
			xrCtx.instance, xrCtx.systemId, 0, &bufSize, null).ok())
		{
			io::printn("WARNING: Failed to query Vulkan device extensions from OpenXR");
		}
		else if (bufSize > 0)
		{
			char[4096] devExtBuf;
			if (bufSize > 4096) { bufSize = 4096; }
			if (catch e = xr::getVulkanDeviceExtensionsKHR(
				xrCtx.instance, xrCtx.systemId, bufSize, &bufSize, &devExtBuf[0]).ok())
			{
				io::printn("WARNING: Failed to get Vulkan device extensions from OpenXR");
			}
			else
			{
				deviceExtCount = parse_extensions(&devExtBuf[0], &deviceExtPtrs);
				io::printfn("OpenXR requires %d Vulkan device extensions:", deviceExtCount);
				for (uint i = 0; i < deviceExtCount; i++)
				{
					io::printfn("  - %s", deviceExtPtrs[i]);
				}
			}
		}
	}

	// Device queue create info
	float queuePriority = 1.0f;
	vk::DeviceQueueCreateInfo queueCreateInfo;
	queueCreateInfo.sType = vk::STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
	queueCreateInfo.pNext = null;
	queueCreateInfo.flags = 0;
	queueCreateInfo.queueFamilyIndex = vkCtx.graphicsQueueFamilyIndex;
	queueCreateInfo.queueCount = 1;
	queueCreateInfo.pQueuePriorities = &queuePriority;

	// Device features
	vk::PhysicalDeviceFeatures deviceFeatures;
	vk::getPhysicalDeviceFeatures(vkCtx.physicalDevice, &deviceFeatures);

	// Device create info with XR-required extensions
	vk::DeviceCreateInfo deviceCreateInfo;
	deviceCreateInfo.sType = vk::STRUCTURE_TYPE_DEVICE_CREATE_INFO;
	deviceCreateInfo.pNext = null;
	deviceCreateInfo.flags = 0;
	deviceCreateInfo.queueCreateInfoCount = 1;
	deviceCreateInfo.pQueueCreateInfos = &queueCreateInfo;
	deviceCreateInfo.enabledLayerCount = 0;
	deviceCreateInfo.ppEnabledLayerNames = null;
	deviceCreateInfo.enabledExtensionCount = deviceExtCount;
	deviceCreateInfo.ppEnabledExtensionNames = (char*)&deviceExtPtrs[0];
	deviceCreateInfo.pEnabledFeatures = &deviceFeatures;

	vk::createDevice(
		vkCtx.physicalDevice, &deviceCreateInfo, null, &vkCtx.device)!!;
	io::printn("Vulkan device created");

	// Get graphics queue
	vk::getDeviceQueue(
		vkCtx.device, vkCtx.graphicsQueueFamilyIndex, 0, &vkCtx.graphicsQueue);

	io::printn("Vulkan graphics queue ready");

	vkCtx.xrReady = true;
	return true;
}

// Cleanup Vulkan resources
fn void cleanup_vulkan(VulkanContext* vkCtx)
{
	io::printn("Cleaning up Vulkan...");

	if (vkCtx.device)
	{
		(void)vk::deviceWaitIdle(vkCtx.device);
		vk::destroyDevice(vkCtx.device, null);
	}

	if (vkCtx.instance)
	{
		vk::destroyInstance(vkCtx.instance, null);
	}

	io::printn("Vulkan cleanup complete");
}
