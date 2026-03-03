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

// Helper: load a function via dlsym (for core functions - goes through loader dispatch)
fn bool load_sym(char* name, void* out_fn_ptr)
{
	void* sym = dlsym(xr_lib_handle, name);
	if (!sym)
	{
		io::printfn("  Failed to load via dlsym: %s", name);
		return false;
	}
	*(void**)out_fn_ptr = sym;
	return true;
}

// Helper: load a function via xrGetInstanceProcAddr (for extension functions)
fn bool load_fn(XrInstance instance, char* name, void* out_fn_ptr)
{
	PFN_xrVoidFunction pfn;
	XrResult result = getInstanceProcAddr(instance, name, &pfn);
	if (failed(result) || pfn == null)
	{
		io::printfn("  Failed to load: %s (result=%d)", name, result);
		return false;
	}
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
	getInstanceProcAddr = (PfnXrGetInstanceProcAddr)proc;

	// Load pre-instance functions via dlsym
	bool ok = true;
	ok = load_sym("xrEnumerateInstanceExtensionProperties", &enumerateInstanceExtensionProperties) && ok;
	ok = load_sym("xrEnumerateApiLayerProperties", &enumerateApiLayerProperties) && ok;
	ok = load_sym("xrCreateInstance", &createInstance) && ok;

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

	// Core instance functions via dlsym (goes through loader dispatch table)
	ok = load_sym("xrDestroyInstance", &destroyInstance) && ok;
	ok = load_sym("xrGetInstanceProperties", &getInstanceProperties) && ok;
	ok = load_sym("xrGetSystem", &getSystem) && ok;
	ok = load_sym("xrGetSystemProperties", &getSystemProperties) && ok;
	ok = load_sym("xrCreateSession", &createSession) && ok;
	ok = load_sym("xrDestroySession", &destroySession) && ok;
	ok = load_sym("xrBeginSession", &beginSession) && ok;
	ok = load_sym("xrEndSession", &endSession) && ok;
	ok = load_sym("xrRequestExitSession", &requestExitSession) && ok;

	// Frame functions
	ok = load_sym("xrWaitFrame", &waitFrame) && ok;
	ok = load_sym("xrBeginFrame", &beginFrame) && ok;
	ok = load_sym("xrEndFrame", &endFrame) && ok;

	// View functions
	ok = load_sym("xrLocateViews", &locateViews) && ok;
	ok = load_sym("xrEnumerateViewConfigurations", &enumerateViewConfigurations) && ok;
	ok = load_sym("xrGetViewConfigurationProperties", &getViewConfigurationProperties) && ok;
	ok = load_sym("xrEnumerateViewConfigurationViews", &enumerateViewConfigurationViews) && ok;

	// Swapchain functions
	ok = load_sym("xrCreateSwapchain", &createSwapchain) && ok;
	ok = load_sym("xrDestroySwapchain", &destroySwapchain) && ok;
	ok = load_sym("xrEnumerateSwapchainImages", &enumerateSwapchainImages) && ok;
	ok = load_sym("xrAcquireSwapchainImage", &acquireSwapchainImage) && ok;
	ok = load_sym("xrWaitSwapchainImage", &waitSwapchainImage) && ok;
	ok = load_sym("xrReleaseSwapchainImage", &releaseSwapchainImage) && ok;

	// Space functions
	ok = load_sym("xrCreateReferenceSpace", &createReferenceSpace) && ok;
	ok = load_sym("xrGetReferenceSpaceBoundsRect", &getReferenceSpaceBoundsRect) && ok;
	ok = load_sym("xrDestroySpace", &destroySpace) && ok;
	ok = load_sym("xrLocateSpace", &locateSpace) && ok;

	// Event and path functions
	ok = load_sym("xrPollEvent", &pollEvent) && ok;
	ok = load_sym("xrStringToPath", &stringToPath) && ok;
	ok = load_sym("xrPathToString", &pathToString) && ok;

	if (!ok)
	{
		io::printn("ERROR: Failed to load some core OpenXR instance functions");
		return false;
	}
	io::printn("  Core instance functions loaded");

	// Extension functions - try dlsym first (loader exports trampolines that
	// correctly unwrap instance handles), fall back to xrGetInstanceProcAddr
	ok = load_sym("xrGetVulkanGraphicsRequirementsKHR", &getVulkanGraphicsRequirementsKHR);
	if (!ok) ok = load_fn(instance, "xrGetVulkanGraphicsRequirementsKHR", &getVulkanGraphicsRequirementsKHR);
	if (!ok) io::printn("  WARNING: Vulkan KHR functions not available");

	if (!load_sym("xrGetVulkanInstanceExtensionsKHR", &getVulkanInstanceExtensionsKHR)) {
		load_fn(instance, "xrGetVulkanInstanceExtensionsKHR", &getVulkanInstanceExtensionsKHR);
	}
	if (!load_sym("xrGetVulkanDeviceExtensionsKHR", &getVulkanDeviceExtensionsKHR)) {
		load_fn(instance, "xrGetVulkanDeviceExtensionsKHR", &getVulkanDeviceExtensionsKHR);
	}
	if (!load_sym("xrGetVulkanGraphicsDeviceKHR", &getVulkanGraphicsDeviceKHR)) {
		load_fn(instance, "xrGetVulkanGraphicsDeviceKHR", &getVulkanGraphicsDeviceKHR);
	}

	// Hand tracking extension functions (optional)
	bool hand_ok = load_sym("xrCreateHandTrackerEXT", &createHandTrackerEXT);
	if (!hand_ok) hand_ok = load_fn(instance, "xrCreateHandTrackerEXT", &createHandTrackerEXT);
	if (hand_ok)
	{
		if (!load_sym("xrDestroyHandTrackerEXT", &destroyHandTrackerEXT)) {
			load_fn(instance, "xrDestroyHandTrackerEXT", &destroyHandTrackerEXT);
		}
		if (!load_sym("xrLocateHandJointsEXT", &locateHandJointsEXT)) {
			load_fn(instance, "xrLocateHandJointsEXT", &locateHandJointsEXT);
		}
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
