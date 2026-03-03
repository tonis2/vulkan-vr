import std::io;
import std::core::mem;
import vk, xr, c3w;
import vr_openxr;
import vr_vulkan;

fn int main(String[] args)
{
	io::printn("=====================================");
	io::printn("Vulkan VR Streamer for WiVRN");
	io::printn("=====================================");
	
	// Initialize OpenXR context
	vr_openxr::OpenXRContext xrCtx;
	vr_vulkan::VulkanContext vkCtx;
	
	// Initialize OpenXR instance
	if (!vr_openxr::init_instance(&xrCtx))
	{
		io::printn("");
		io::printn("ERROR: Failed to initialize OpenXR instance");
		io::printn("Make sure WiVRN is running");
		return 1;
	}
	
	// Initialize OpenXR system
	if (!vr_openxr::init_system(&xrCtx))
	{
		io::printn("Failed to initialize OpenXR system");
		vr_openxr::cleanup(&xrCtx);
		return 1;
	}
	
	// Get view configuration
	if (!vr_openxr::get_view_configuration(&xrCtx))
	{
		io::printn("Failed to get view configuration");
		vr_openxr::cleanup(&xrCtx);
		return 1;
	}
	
	// Initialize Vulkan with OpenXR
	if (!vr_vulkan::init_vulkan(&xrCtx, &vkCtx))
	{
		io::printn("Failed to initialize Vulkan");
		vr_openxr::cleanup(&xrCtx);
		return 1;
	}
	
	// Create OpenXR session with Vulkan graphics binding
	if (!vr_openxr::create_vulkan_session(
		&xrCtx,
		vkCtx.instance,
		vkCtx.physicalDevice,
		vkCtx.device,
		vkCtx.graphicsQueueFamilyIndex,
		0))
	{
		io::printn("Failed to create OpenXR session with Vulkan binding");
		vr_openxr::cleanup(&xrCtx);
		vr_vulkan::cleanup_vulkan(&vkCtx);
		return 1;
	}

	// Create stereo swapchains
	if (!vr_openxr::create_stereo_swapchains(&xrCtx))
	{
		io::printn("Failed to create stereo swapchains");
		vr_openxr::cleanup(&xrCtx);
		vr_vulkan::cleanup_vulkan(&vkCtx);
		return 1;
	}
	
	io::printn("");
	io::printn("=====================================");
	io::printn("✓ VR System Initialized Successfully!");
	io::printn("=====================================");
	io::printn("");
	io::printn("Ready to render to Meta Quest 3");
	io::printn("Resolution: 2064x2164 per eye");
	io::printn("");
	io::printn("Put on your Quest 3 and look around!");
	io::printn("(Rendering loop not yet implemented)");
	io::printn("=====================================");
	
	// Poll for session events (quick test)
	io::printn("Polling for session events (3 seconds)...");
	for (int i = 0; i < 60; i++)
	{
		vr_openxr::poll_events(&xrCtx);
		
		if (xrCtx.sessionState == xr::XR_SESSION_STATE_EXITING ||
		    xrCtx.sessionState == xr::XR_SESSION_STATE_LOSS_PENDING)
		{
			io::printn("Session exiting...");
			break;
		}
		
		// Small delay - ~60fps
		for (int j = 0; j < 10000000; j++) {}
	}
	
	// Cleanup (OpenXR first since it references Vulkan resources)
	vr_openxr::cleanup(&xrCtx);
	vr_vulkan::cleanup_vulkan(&vkCtx);
	
	return 0;
}
