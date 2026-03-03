module xr;
import std::io;

// dlopen/dlsym/dlclose from libc
const int RTLD_LAZY = 1;

extern fn void* dlopen(char* filename, int flags) @extern("dlopen");
extern fn void* dlsym(void* handle, char* symbol) @extern("dlsym");
extern fn int dlclose(void* handle) @extern("dlclose");
extern fn char* dlerror() @extern("dlerror");

// Library handle
void* xr_lib_handle;

// Helper: load a single function via xrGetInstanceProcAddr
fn bool load_fn(XrInstance instance, char* name, void* out_fn_ptr)
{
	PFN_xrVoidFunction pfn;
	XrResult result = xrGetInstanceProcAddr(instance, name, &pfn);
	if (failed(result) || pfn == null)
	{
		io::printfn("  Failed to load: %s (result=%d)", name, result);
		return false;
	}
	// Copy raw function pointer value into the target variable
	*(void**)out_fn_ptr = (void*)pfn;
	return true;
}

// Phase 1: dlopen the loader and resolve pre-instance functions
fn bool load()
{
	io::printn("Loading OpenXR loader dynamically...");

	xr_lib_handle = dlopen("libopenxr_loader.so.1", RTLD_LAZY);
	if (!xr_lib_handle)
	{
		io::printfn("ERROR: Failed to load libopenxr_loader.so.1: %s", dlerror());
		return false;
	}

	// Resolve xrGetInstanceProcAddr via dlsym
	void* proc = dlsym(xr_lib_handle, "xrGetInstanceProcAddr");
	if (!proc)
	{
		io::printfn("ERROR: Failed to find xrGetInstanceProcAddr: %s", dlerror());
		dlclose(xr_lib_handle);
		xr_lib_handle = null;
		return false;
	}
	xrGetInstanceProcAddr = (PfnXrGetInstanceProcAddr)proc;

	// Load pre-instance functions (instance = null)
	bool ok = true;
	ok = load_fn(null, "xrEnumerateInstanceExtensionProperties", &xrEnumerateInstanceExtensionProperties) && ok;
	ok = load_fn(null, "xrEnumerateApiLayerProperties", &xrEnumerateApiLayerProperties) && ok;
	ok = load_fn(null, "xrCreateInstance", &xrCreateInstance) && ok;

	if (!ok)
	{
		io::printn("ERROR: Failed to load pre-instance OpenXR functions");
		dlclose(xr_lib_handle);
		xr_lib_handle = null;
		return false;
	}

	io::printn("  Pre-instance functions loaded");
	return true;
}

// Phase 2: load all instance-level and extension functions
fn bool load_instance_fns(XrInstance instance)
{
	io::printn("Loading OpenXR instance functions...");
	bool ok = true;

	// Core instance functions
	ok = load_fn(instance, "xrDestroyInstance", &xrDestroyInstance) && ok;
	ok = load_fn(instance, "xrGetInstanceProperties", &xrGetInstanceProperties) && ok;
	ok = load_fn(instance, "xrGetSystem", &xrGetSystem) && ok;
	ok = load_fn(instance, "xrGetSystemProperties", &xrGetSystemProperties) && ok;
	ok = load_fn(instance, "xrCreateSession", &xrCreateSession) && ok;
	ok = load_fn(instance, "xrDestroySession", &xrDestroySession) && ok;
	ok = load_fn(instance, "xrBeginSession", &xrBeginSession) && ok;
	ok = load_fn(instance, "xrEndSession", &xrEndSession) && ok;
	ok = load_fn(instance, "xrRequestExitSession", &xrRequestExitSession) && ok;

	// Frame functions
	ok = load_fn(instance, "xrWaitFrame", &xrWaitFrame) && ok;
	ok = load_fn(instance, "xrBeginFrame", &xrBeginFrame) && ok;
	ok = load_fn(instance, "xrEndFrame", &xrEndFrame) && ok;

	// View functions
	ok = load_fn(instance, "xrLocateViews", &xrLocateViews) && ok;
	ok = load_fn(instance, "xrEnumerateViewConfigurations", &xrEnumerateViewConfigurations) && ok;
	ok = load_fn(instance, "xrGetViewConfigurationProperties", &xrGetViewConfigurationProperties) && ok;
	ok = load_fn(instance, "xrEnumerateViewConfigurationViews", &xrEnumerateViewConfigurationViews) && ok;

	// Swapchain functions
	ok = load_fn(instance, "xrCreateSwapchain", &xrCreateSwapchain) && ok;
	ok = load_fn(instance, "xrDestroySwapchain", &xrDestroySwapchain) && ok;
	ok = load_fn(instance, "xrEnumerateSwapchainImages", &xrEnumerateSwapchainImages) && ok;
	ok = load_fn(instance, "xrAcquireSwapchainImage", &xrAcquireSwapchainImage) && ok;
	ok = load_fn(instance, "xrWaitSwapchainImage", &xrWaitSwapchainImage) && ok;
	ok = load_fn(instance, "xrReleaseSwapchainImage", &xrReleaseSwapchainImage) && ok;

	// Space functions
	ok = load_fn(instance, "xrCreateReferenceSpace", &xrCreateReferenceSpace) && ok;
	ok = load_fn(instance, "xrGetReferenceSpaceBoundsRect", &xrGetReferenceSpaceBoundsRect) && ok;
	ok = load_fn(instance, "xrDestroySpace", &xrDestroySpace) && ok;
	ok = load_fn(instance, "xrLocateSpace", &xrLocateSpace) && ok;

	// Event and path functions
	ok = load_fn(instance, "xrPollEvent", &xrPollEvent) && ok;
	ok = load_fn(instance, "xrStringToPath", &xrStringToPath) && ok;
	ok = load_fn(instance, "xrPathToString", &xrPathToString) && ok;

	if (!ok)
	{
		io::printn("ERROR: Failed to load some core OpenXR instance functions");
		return false;
	}
	io::printn("  Core instance functions loaded");

	// Vulkan KHR extension functions
	ok = load_fn(instance, "xrGetVulkanGraphicsRequirementsKHR", &xrGetVulkanGraphicsRequirementsKHR);
	if (!ok) io::printn("  WARNING: Vulkan KHR functions not available");

	load_fn(instance, "xrGetVulkanInstanceExtensionsKHR", &xrGetVulkanInstanceExtensionsKHR);
	load_fn(instance, "xrGetVulkanDeviceExtensionsKHR", &xrGetVulkanDeviceExtensionsKHR);
	load_fn(instance, "xrGetVulkanGraphicsDeviceKHR", &xrGetVulkanGraphicsDeviceKHR);

	// Hand tracking extension functions (optional)
	bool hand_ok = load_fn(instance, "xrCreateHandTrackerEXT", &xrCreateHandTrackerEXT);
	if (hand_ok)
	{
		load_fn(instance, "xrDestroyHandTrackerEXT", &xrDestroyHandTrackerEXT);
		load_fn(instance, "xrLocateHandJointsEXT", &xrLocateHandJointsEXT);
		io::printn("  Hand tracking functions loaded");
	}
	else
	{
		io::printn("  Hand tracking functions not available");
	}

	return true;
}

// Cleanup: close the shared library
fn void unload()
{
	if (xr_lib_handle)
	{
		dlclose(xr_lib_handle);
		xr_lib_handle = null;
		io::printn("OpenXR loader unloaded");
	}
}
