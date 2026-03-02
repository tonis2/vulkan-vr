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

// Initialize Vulkan with minimal requirements
fn bool init_vulkan(vr_openxr::OpenXRContext* xrCtx, VulkanContext* vkCtx)
{
	io::printn("Initializing Vulkan...");
	
	// Vulkan application info
	vk::ApplicationInfo appInfo;
	appInfo.sType = vk::STRUCTURE_TYPE_APPLICATION_INFO;
	appInfo.pNext = null;
	appInfo.pApplicationName = "Vulkan VR Streamer";
	appInfo.applicationVersion = ((1 << 22) | (0 << 12) | 0);
	appInfo.pEngineName = "C3 Vulkan Engine";
	appInfo.engineVersion = ((1 << 22) | (0 << 12) | 0);
	appInfo.apiVersion = ((1 << 22) | (2 << 12) | 0);
	
	// Vulkan instance create info - NO EXTENSIONS (minimal setup)
	vk::InstanceCreateInfo createInfo;
	createInfo.sType = vk::STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
	createInfo.pNext = null;
	createInfo.flags = 0;
	createInfo.pApplicationInfo = &appInfo;
	createInfo.enabledLayerCount = 0;
	createInfo.ppEnabledLayerNames = null;
	createInfo.enabledExtensionCount = 0;  // No extensions for now
	createInfo.ppEnabledExtensionNames = null;
	
	vk::createInstance(&createInfo, null, &vkCtx.instance)!!;
	io::printn("✓ Vulkan instance created");
	
	// Enumerate physical devices
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
	io::printfn("✓ Physical device selected (%d available)", deviceCount);
	
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
	
	io::printfn("✓ Graphics queue family: %d", vkCtx.graphicsQueueFamilyIndex);
	
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
	
	// Device create info - NO EXTENSIONS
	vk::DeviceCreateInfo deviceCreateInfo;
	deviceCreateInfo.sType = vk::STRUCTURE_TYPE_DEVICE_CREATE_INFO;
	deviceCreateInfo.pNext = null;
	deviceCreateInfo.flags = 0;
	deviceCreateInfo.queueCreateInfoCount = 1;
	deviceCreateInfo.pQueueCreateInfos = &queueCreateInfo;
	deviceCreateInfo.enabledLayerCount = 0;
	deviceCreateInfo.ppEnabledLayerNames = null;
	deviceCreateInfo.enabledExtensionCount = 0;  // No extensions
	deviceCreateInfo.ppEnabledExtensionNames = null;
	deviceCreateInfo.pEnabledFeatures = &deviceFeatures;
	
	vk::createDevice(
		vkCtx.physicalDevice, &deviceCreateInfo, null, &vkCtx.device)!!;
	io::printn("✓ Vulkan device created");
	
	// Get graphics queue
	vk::getDeviceQueue(
		vkCtx.device, vkCtx.graphicsQueueFamilyIndex, 0, &vkCtx.graphicsQueue);
	
	io::printn("✓ Vulkan graphics queue ready");
	
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
