module xr;
import std::io;

// OpenXR Version and Constants
const uint XR_VERSION_1_0 = 1;
const uint XR_MAX_EXTENSION_NAME_SIZE = 128;
const uint XR_MAX_API_LAYER_NAME_SIZE = 256;
const uint XR_MAX_APPLICATION_NAME_SIZE = 128;
const uint XR_MAX_ENGINE_NAME_SIZE = 128;
const uint XR_MAX_SYSTEM_NAME_SIZE = 256;
const uint XR_MAX_PATH_LENGTH = 256;
const uint XR_MAX_STRUCTURE_NAME_SIZE = 64;
const uint XR_MAX_RESULT_STRING_SIZE = 64;
const uint XR_MAX_ACTION_SET_NAME_SIZE = 64;
const uint XR_MAX_ACTION_NAME_SIZE = 64;
const uint XR_MAX_LOCALIZED_ACTION_NAME_SIZE = 128;
const uint XR_MAX_RUNTIME_NAME_SIZE = 128;
const uint XR_MIN_COMPOSITION_LAYERS_SUPPORTED = 16;
const ulong XR_NULL_SYSTEM_ID = 0;
const ulong XR_NULL_PATH = 0;
const uint XR_TRUE = 1;
const uint XR_FALSE = 0;
const long XR_NO_DURATION = 0;
const long XR_INFINITE_DURATION = 0x7fffffffffffffffLL;
const uint XR_MAX_EVENT_DATA_SIZE = 4000;

// Extension Names
const char[*] XR_KHR_VULKAN_ENABLE_EXTENSION_NAME = "XR_KHR_vulkan_enable";
const char[*] XR_EXT_HAND_TRACKING_EXTENSION_NAME = "XR_EXT_hand_tracking";
const char[*] XR_EXT_HAND_TRACKING_DATA_SOURCE_EXTENSION_NAME = "XR_EXT_hand_tracking_data_source";

// Result codes (success and errors)
typedef XrResult = int;
const XrResult XR_SUCCESS = 0;
const XrResult XR_TIMEOUT_EXPIRED = 1;
const XrResult XR_SESSION_LOSS_PENDING = 3;
const XrResult XR_EVENT_UNAVAILABLE = 4;
const XrResult XR_SPACE_BOUNDS_UNAVAILABLE = 7;
const XrResult XR_SESSION_NOT_FOCUSED = 8;
const XrResult XR_FRAME_DISCARDED = 9;
const XrResult XR_ERROR_VALIDATION_FAILURE = -1;
const XrResult XR_ERROR_RUNTIME_FAILURE = -2;
const XrResult XR_ERROR_OUT_OF_MEMORY = -3;
const XrResult XR_ERROR_API_VERSION_UNSUPPORTED = -4;
const XrResult XR_ERROR_INITIALIZATION_FAILED = -6;
const XrResult XR_ERROR_FUNCTION_UNSUPPORTED = -7;
const XrResult XR_ERROR_FEATURE_UNSUPPORTED = -8;
const XrResult XR_ERROR_EXTENSION_NOT_PRESENT = -9;
const XrResult XR_ERROR_LIMIT_REACHED = -10;
const XrResult XR_ERROR_SIZE_INSUFFICIENT = -11;
const XrResult XR_ERROR_HANDLE_INVALID = -12;
const XrResult XR_ERROR_INSTANCE_LOST = -13;
const XrResult XR_ERROR_SESSION_RUNNING = -14;
const XrResult XR_ERROR_SESSION_NOT_RUNNING = -16;
const XrResult XR_ERROR_SESSION_LOST = -17;
const XrResult XR_ERROR_SYSTEM_INVALID = -18;
const XrResult XR_ERROR_PATH_INVALID = -19;
const XrResult XR_ERROR_PATH_COUNT_EXCEEDED = -20;
const XrResult XR_ERROR_TIME_INVALID = -30;
const XrResult XR_ERROR_REFERENCE_SPACE_UNSUPPORTED = -31;
const XrResult XR_ERROR_FILE_ACCESS_ERROR = -32;
const XrResult XR_ERROR_FILE_CONTENTS_INVALID = -33;
const XrResult XR_ERROR_FORM_FACTOR_UNSUPPORTED = -34;
const XrResult XR_ERROR_FORM_FACTOR_UNAVAILABLE = -35;
const XrResult XR_ERROR_GRAPHICS_DEVICE_INVALID = -38;
const XrResult XR_ERROR_POSE_INVALID = -39;
const XrResult XR_ERROR_INDEX_OUT_OF_RANGE = -40;
const XrResult XR_ERROR_VIEW_CONFIGURATION_TYPE_UNSUPPORTED = -41;
const XrResult XR_ERROR_ENVIRONMENT_BLEND_MODE_UNSUPPORTED = -42;
const XrResult XR_ERROR_ACTIONSETS_ALREADY_ATTACHED = -47;
const XrResult XR_ERROR_GRAPHICS_REQUIREMENTS_CALL_MISSING = -50;
const XrResult XR_ERROR_RUNTIME_UNAVAILABLE = -51;

// Structure types
typedef XrStructureType = uint;
const XrStructureType XR_TYPE_UNKNOWN = 0;
const XrStructureType XR_TYPE_API_LAYER_PROPERTIES = 1;
const XrStructureType XR_TYPE_EXTENSION_PROPERTIES = 2;
const XrStructureType XR_TYPE_INSTANCE_CREATE_INFO = 3;
const XrStructureType XR_TYPE_SYSTEM_GET_INFO = 4;
const XrStructureType XR_TYPE_SYSTEM_PROPERTIES = 5;
const XrStructureType XR_TYPE_VIEW_LOCATE_INFO = 6;
const XrStructureType XR_TYPE_VIEW = 7;
const XrStructureType XR_TYPE_SESSION_CREATE_INFO = 8;
const XrStructureType XR_TYPE_SWAPCHAIN_CREATE_INFO = 9;
const XrStructureType XR_TYPE_SESSION_BEGIN_INFO = 10;
const XrStructureType XR_TYPE_VIEW_STATE = 11;
const XrStructureType XR_TYPE_FRAME_END_INFO = 12;
const XrStructureType XR_TYPE_HAPTIC_VIBRATION = 13;
const XrStructureType XR_TYPE_EVENT_DATA_BUFFER = 16;
const XrStructureType XR_TYPE_EVENT_DATA_INSTANCE_LOSS_PENDING = 17;
const XrStructureType XR_TYPE_EVENT_DATA_SESSION_STATE_CHANGED = 18;
const XrStructureType XR_TYPE_ACTION_STATE_BOOLEAN = 23;
const XrStructureType XR_TYPE_ACTION_STATE_FLOAT = 24;
const XrStructureType XR_TYPE_ACTION_STATE_VECTOR2F = 25;
const XrStructureType XR_TYPE_ACTION_STATE_POSE = 27;
const XrStructureType XR_TYPE_ACTION_SET_CREATE_INFO = 28;
const XrStructureType XR_TYPE_ACTION_CREATE_INFO = 29;
const XrStructureType XR_TYPE_INSTANCE_PROPERTIES = 32;
const XrStructureType XR_TYPE_FRAME_WAIT_INFO = 33;
const XrStructureType XR_TYPE_COMPOSITION_LAYER_PROJECTION = 35;
const XrStructureType XR_TYPE_COMPOSITION_LAYER_QUAD = 36;
const XrStructureType XR_TYPE_REFERENCE_SPACE_CREATE_INFO = 37;
const XrStructureType XR_TYPE_ACTION_SPACE_CREATE_INFO = 38;
const XrStructureType XR_TYPE_EVENT_DATA_REFERENCE_SPACE_CHANGE_PENDING = 40;
const XrStructureType XR_TYPE_VIEW_CONFIGURATION_VIEW = 41;
const XrStructureType XR_TYPE_SPACE_LOCATION = 42;
const XrStructureType XR_TYPE_SPACE_VELOCITY = 43;
const XrStructureType XR_TYPE_FRAME_STATE = 44;
const XrStructureType XR_TYPE_VIEW_CONFIGURATION_PROPERTIES = 45;
const XrStructureType XR_TYPE_FRAME_BEGIN_INFO = 46;
const XrStructureType XR_TYPE_COMPOSITION_LAYER_PROJECTION_VIEW = 48;
const XrStructureType XR_TYPE_EVENT_DATA_EVENTS_LOST = 49;
const XrStructureType XR_TYPE_INTERACTION_PROFILE_SUGGESTED_BINDING = 51;
const XrStructureType XR_TYPE_EVENT_DATA_INTERACTION_PROFILE_CHANGED = 52;
const XrStructureType XR_TYPE_INTERACTION_PROFILE_STATE = 53;
const XrStructureType XR_TYPE_SWAPCHAIN_IMAGE_ACQUIRE_INFO = 55;
const XrStructureType XR_TYPE_SWAPCHAIN_IMAGE_WAIT_INFO = 56;
const XrStructureType XR_TYPE_SWAPCHAIN_IMAGE_RELEASE_INFO = 57;
const XrStructureType XR_TYPE_ACTION_STATE_GET_INFO = 58;
const XrStructureType XR_TYPE_HAPTIC_ACTION_INFO = 59;
const XrStructureType XR_TYPE_SESSION_ACTION_SETS_ATTACH_INFO = 60;
const XrStructureType XR_TYPE_ACTIONS_SYNC_INFO = 61;
const XrStructureType XR_TYPE_GRAPHICS_BINDING_VULKAN_KHR = 1000025000;
const XrStructureType XR_TYPE_SWAPCHAIN_IMAGE_VULKAN_KHR = 1000025001;
const XrStructureType XR_TYPE_GRAPHICS_REQUIREMENTS_VULKAN_KHR = 1000025002;
const XrStructureType XR_TYPE_SYSTEM_HAND_TRACKING_PROPERTIES_EXT = 1000051000;
const XrStructureType XR_TYPE_HAND_TRACKER_CREATE_INFO_EXT = 1000051001;
const XrStructureType XR_TYPE_HAND_JOINTS_LOCATE_INFO_EXT = 1000051002;
const XrStructureType XR_TYPE_HAND_JOINT_LOCATIONS_EXT = 1000051003;
const XrStructureType XR_TYPE_HAND_TRACKING_DATA_SOURCE_INFO_EXT = 1000428000;
const XrStructureType XR_TYPE_HAND_TRACKING_DATA_SOURCE_STATE_EXT = 1000428001;

// Form factor
typedef XrFormFactor = uint;
const XrFormFactor XR_FORM_FACTOR_HEAD_MOUNTED_DISPLAY = 1;
const XrFormFactor XR_FORM_FACTOR_HANDHELD_DISPLAY = 2;

// View configuration type
typedef XrViewConfigurationType = uint;
const XrViewConfigurationType XR_VIEW_CONFIGURATION_TYPE_PRIMARY_MONO = 1;
const XrViewConfigurationType XR_VIEW_CONFIGURATION_TYPE_PRIMARY_STEREO = 2;

// Environment blend mode
typedef XrEnvironmentBlendMode = uint;
const XrEnvironmentBlendMode XR_ENVIRONMENT_BLEND_MODE_OPAQUE = 1;
const XrEnvironmentBlendMode XR_ENVIRONMENT_BLEND_MODE_ADDITIVE = 2;
const XrEnvironmentBlendMode XR_ENVIRONMENT_BLEND_MODE_ALPHA_BLEND = 3;

// Reference space type
typedef XrReferenceSpaceType = uint;
const XrReferenceSpaceType XR_REFERENCE_SPACE_TYPE_VIEW = 1;
const XrReferenceSpaceType XR_REFERENCE_SPACE_TYPE_LOCAL = 2;
const XrReferenceSpaceType XR_REFERENCE_SPACE_TYPE_STAGE = 3;
const XrReferenceSpaceType XR_REFERENCE_SPACE_TYPE_LOCAL_FLOOR = 1000426000;

// Action type
typedef XrActionType = uint;
const XrActionType XR_ACTION_TYPE_BOOLEAN_INPUT = 1;
const XrActionType XR_ACTION_TYPE_FLOAT_INPUT = 2;
const XrActionType XR_ACTION_TYPE_VECTOR2F_INPUT = 3;
const XrActionType XR_ACTION_TYPE_POSE_INPUT = 4;
const XrActionType XR_ACTION_TYPE_VIBRATION_OUTPUT = 100;

// Eye visibility
typedef XrEyeVisibility = uint;
const XrEyeVisibility XR_EYE_VISIBILITY_BOTH = 0;
const XrEyeVisibility XR_EYE_VISIBILITY_LEFT = 1;
const XrEyeVisibility XR_EYE_VISIBILITY_RIGHT = 2;

// Session state
typedef XrSessionState = uint;
const XrSessionState XR_SESSION_STATE_UNKNOWN = 0;
const XrSessionState XR_SESSION_STATE_IDLE = 1;
const XrSessionState XR_SESSION_STATE_READY = 2;
const XrSessionState XR_SESSION_STATE_SYNCHRONIZED = 3;
const XrSessionState XR_SESSION_STATE_VISIBLE = 4;
const XrSessionState XR_SESSION_STATE_FOCUSED = 5;
const XrSessionState XR_SESSION_STATE_STOPPING = 6;
const XrSessionState XR_SESSION_STATE_LOSS_PENDING = 7;
const XrSessionState XR_SESSION_STATE_EXITING = 8;

// Hand joints (for hand tracking)
typedef XrHandJointEXT = uint;
const XrHandJointEXT XR_HAND_JOINT_PALM_EXT = 0;
const XrHandJointEXT XR_HAND_JOINT_WRIST_EXT = 1;
const XrHandJointEXT XR_HAND_JOINT_THUMB_METACARPAL_EXT = 2;
const XrHandJointEXT XR_HAND_JOINT_THUMB_PROXIMAL_EXT = 3;
const XrHandJointEXT XR_HAND_JOINT_THUMB_DISTAL_EXT = 4;
const XrHandJointEXT XR_HAND_JOINT_THUMB_TIP_EXT = 5;
const XrHandJointEXT XR_HAND_JOINT_INDEX_METACARPAL_EXT = 6;
const XrHandJointEXT XR_HAND_JOINT_INDEX_PROXIMAL_EXT = 7;
const XrHandJointEXT XR_HAND_JOINT_INDEX_INTERMEDIATE_EXT = 8;
const XrHandJointEXT XR_HAND_JOINT_INDEX_DISTAL_EXT = 9;
const XrHandJointEXT XR_HAND_JOINT_INDEX_TIP_EXT = 10;
const XrHandJointEXT XR_HAND_JOINT_MIDDLE_METACARPAL_EXT = 11;
const XrHandJointEXT XR_HAND_JOINT_MIDDLE_PROXIMAL_EXT = 12;
const XrHandJointEXT XR_HAND_JOINT_MIDDLE_INTERMEDIATE_EXT = 13;
const XrHandJointEXT XR_HAND_JOINT_MIDDLE_DISTAL_EXT = 14;
const XrHandJointEXT XR_HAND_JOINT_MIDDLE_TIP_EXT = 15;
const XrHandJointEXT XR_HAND_JOINT_RING_METACARPAL_EXT = 16;
const XrHandJointEXT XR_HAND_JOINT_RING_PROXIMAL_EXT = 17;
const XrHandJointEXT XR_HAND_JOINT_RING_INTERMEDIATE_EXT = 18;
const XrHandJointEXT XR_HAND_JOINT_RING_DISTAL_EXT = 19;
const XrHandJointEXT XR_HAND_JOINT_RING_TIP_EXT = 20;
const XrHandJointEXT XR_HAND_JOINT_LITTLE_METACARPAL_EXT = 21;
const XrHandJointEXT XR_HAND_JOINT_LITTLE_PROXIMAL_EXT = 22;
const XrHandJointEXT XR_HAND_JOINT_LITTLE_INTERMEDIATE_EXT = 23;
const XrHandJointEXT XR_HAND_JOINT_LITTLE_DISTAL_EXT = 24;
const XrHandJointEXT XR_HAND_JOINT_LITTLE_TIP_EXT = 25;
const XrHandJointEXT XR_HAND_JOINT_MAX_ENUM_EXT = 26;

// Hand (left or right)
typedef XrHandEXT = uint;
const XrHandEXT XR_HAND_LEFT_EXT = 1;
const XrHandEXT XR_HAND_RIGHT_EXT = 2;

// Hand joint set
typedef XrHandJointSetEXT = uint;
const XrHandJointSetEXT XR_HAND_JOINT_SET_DEFAULT_EXT = 0;

// Object type
typedef XrObjectType = uint;
const XrObjectType XR_OBJECT_TYPE_UNKNOWN = 0;
const XrObjectType XR_OBJECT_TYPE_INSTANCE = 1;
const XrObjectType XR_OBJECT_TYPE_SESSION = 2;
const XrObjectType XR_OBJECT_TYPE_SWAPCHAIN = 3;
const XrObjectType XR_OBJECT_TYPE_SPACE = 4;
const XrObjectType XR_OBJECT_TYPE_ACTION_SET = 5;
const XrObjectType XR_OBJECT_TYPE_ACTION = 6;
const XrObjectType XR_OBJECT_TYPE_HAND_TRACKER_EXT = 1000051000;

// Base types
typedef XrVersion = ulong;
typedef XrFlags64 = ulong;
typedef XrSystemId = ulong;
typedef XrBool32 = uint;
typedef XrPath = ulong;
typedef XrTime = long;
typedef XrDuration = long;
typedef XrInstance = void*;
typedef XrSession = void*;
typedef XrSpace = void*;
typedef XrSwapchain = void*;
typedef XrAction = void*;
typedef XrActionSet = void*;
typedef XrHandTrackerEXT = void*;

// Helper functions (converted from macros)
fn bool succeeded(XrResult result) => result >= 0;
fn bool failed(XrResult result) => result < 0;
fn bool unqualified_success(XrResult result) => result == 0;

// Helper functions
fn ulong make_version(uint major, uint minor, uint patch)
{
	return (((ulong)major & 0xffffULL) << 48) | (((ulong)minor & 0xffffULL) << 32) | ((ulong)patch & 0xffffffffULL);
}

// Vector types
struct XrVector2f
{
	float x;
	float y;
}

struct XrVector3f
{
	float x;
	float y;
	float z;
}

struct XrVector4f
{
	float x;
	float y;
	float z;
	float w;
}

struct XrQuaternionf
{
	float x;
	float y;
	float z;
	float w;
}

struct XrColor4f
{
	float r;
	float g;
	float b;
	float a;
}

// Pose structure
struct XrPosef
{
	XrQuaternionf orientation;
	XrVector3f position;
}

// Matrix structure
struct XrMatrix4x4f
{
	float[16] m;
}

// Base header structure
struct XrBaseInStructure
{
	XrStructureType type;
	void* next;
}

struct XrBaseOutStructure
{
	XrStructureType type;
	void* next;
}

// Extension properties
struct XrExtensionProperties
{
	XrStructureType type;
	void* next;
	char[XR_MAX_EXTENSION_NAME_SIZE] extensionName;
	uint extensionVersion;
}

// Application info
struct XrApplicationInfo
{
	char[XR_MAX_APPLICATION_NAME_SIZE] applicationName;
	XrVersion applicationVersion;
	char[XR_MAX_ENGINE_NAME_SIZE] engineName;
	XrVersion engineVersion;
	XrVersion apiVersion;
}

// Instance create info
struct XrInstanceCreateInfo
{
	XrStructureType type;
	void* next;
	XrInstanceCreateFlags createFlags;
	XrApplicationInfo applicationInfo;
	uint enabledApiLayerCount;
	char** enabledApiLayerNames;
	uint enabledExtensionCount;
	char** enabledExtensionNames;
}

// Instance properties
struct XrInstanceProperties
{
	XrStructureType type;
	void* next;
	XrVersion runtimeVersion;
	char[XR_MAX_RUNTIME_NAME_SIZE] runtimeName;
}

// System get info
struct XrSystemGetInfo
{
	XrStructureType type;
	void* next;
	XrFormFactor formFactor;
}

// System graphics properties
struct XrSystemGraphicsProperties
{
	uint maxSwapchainImageWidth;
	uint maxSwapchainImageHeight;
	uint maxLayerCount;
}

// System tracking properties
struct XrSystemTrackingProperties
{
	XrBool32 orientationTracking;
	XrBool32 positionTracking;
}

// System properties
struct XrSystemProperties
{
	XrStructureType type;
	void* next;
	XrSystemId systemId;
	uint vendorId;
	char[XR_MAX_SYSTEM_NAME_SIZE] systemName;
	XrSystemGraphicsProperties graphicsProperties;
	XrSystemTrackingProperties trackingProperties;
}

// Graphics binding for Vulkan
struct XrGraphicsBindingVulkanKHR
{
	XrStructureType type;
	void* next;
	void* instance;
	void* physicalDevice;
	void* device;
	uint queueFamilyIndex;
	uint queueIndex;
}

// Graphics requirements for Vulkan
struct XrGraphicsRequirementsVulkanKHR
{
	XrStructureType type;
	void* next;
	XrVersion minApiVersionSupported;
	XrVersion maxApiVersionSupported;
}

// Session create info
struct XrSessionCreateInfo
{
	XrStructureType type;
	void* next;
	XrSessionCreateFlags createFlags;
	XrSystemId systemId;
}

// Session begin info
struct XrSessionBeginInfo
{
	XrStructureType type;
	void* next;
	XrViewConfigurationType primaryViewConfigurationType;
}

// Reference space create info
struct XrReferenceSpaceCreateInfo
{
	XrStructureType type;
	void* next;
	XrReferenceSpaceType referenceSpaceType;
	XrPosef poseInReferenceSpace;
}

// View configuration view
struct XrViewConfigurationView
{
	XrStructureType type;
	void* next;
	uint recommendedImageRectWidth;
	uint maxImageRectWidth;
	uint recommendedImageRectHeight;
	uint maxImageRectHeight;
	uint recommendedSwapchainSampleCount;
	uint maxSwapchainSampleCount;
}

// Swapchain create info
struct XrSwapchainCreateInfo
{
	XrStructureType type;
	void* next;
	XrSwapchainCreateFlags createFlags;
	XrSwapchainUsageFlags usageFlags;
	long format;
	uint sampleCount;
	uint width;
	uint height;
	uint faceCount;
	uint arraySize;
	uint mipCount;
}

// View locate info
struct XrViewLocateInfo
{
	XrStructureType type;
	void* next;
	XrViewConfigurationType viewConfigurationType;
	XrTime displayTime;
	XrSpace space;
}

// View state
struct XrViewState
{
	XrStructureType type;
	void* next;
	XrViewStateFlags viewStateFlags;
}

// View
struct XrView
{
	XrStructureType type;
	void* next;
	XrPosef pose;
	XrFovf fov;
}

// Field of view
struct XrFovf
{
	float angleLeft;
	float angleRight;
	float angleUp;
	float angleDown;
}

// Frame wait info
struct XrFrameWaitInfo
{
	XrStructureType type;
	void* next;
}

// Frame state
struct XrFrameState
{
	XrStructureType type;
	void* next;
	XrTime predictedDisplayTime;
	XrDuration predictedDisplayPeriod;
	XrBool32 shouldRender;
}

// Frame begin info
struct XrFrameBeginInfo
{
	XrStructureType type;
	void* next;
}

// Composition layer projection view
struct XrCompositionLayerProjectionView
{
	XrStructureType type;
	void* next;
	XrPosef pose;
	XrFovf fov;
	XrSwapchainSubImage subImage;
}

// Swapchain sub-image
struct XrSwapchainSubImage
{
	XrSwapchain swapchain;
	XrRect2Di imageRect;
	uint imageArrayIndex;
}

// Rectangle 2D
struct XrRect2Di
{
	XrOffset2Di offset;
	XrExtent2Di extent;
}

// Offset 2D
struct XrOffset2Di
{
	int x;
	int y;
}

// Extent 2D
struct XrExtent2Di
{
	int width;
	int height;
}

// Composition layer projection
struct XrCompositionLayerProjection
{
	XrStructureType type;
	void* next;
	XrCompositionLayerFlags layerFlags;
	XrSpace space;
	uint viewCount;
	XrCompositionLayerProjectionView* views;
}

// Composition layer quad
struct XrCompositionLayerQuad
{
	XrStructureType type;
	void* next;
	XrCompositionLayerFlags layerFlags;
	XrSpace space;
	XrEyeVisibility eyeVisibility;
	XrSwapchainSubImage subImage;
	XrPosef pose;
	XrVector2f size;
}

// Frame end info
struct XrFrameEndInfo
{
	XrStructureType type;
	void* next;
	XrTime displayTime;
	XrEnvironmentBlendMode environmentBlendMode;
	uint layerCount;
	XrCompositionLayerBaseHeader** layers;
}

// Composition layer base header
struct XrCompositionLayerBaseHeader
{
	XrStructureType type;
	void* next;
	XrCompositionLayerFlags layerFlags;
	XrSpace space;
}

// Event data buffer
struct XrEventDataBuffer
{
	XrStructureType type;
	void* next;
	char[XR_MAX_EVENT_DATA_SIZE] varying;
}

// Event data session state changed
struct XrEventDataSessionStateChanged
{
	XrStructureType type;
	void* next;
	XrSession session;
	XrSessionState state;
	XrTime time;
}

// Space location
struct XrSpaceLocation
{
	XrStructureType type;
	void* next;
	XrSpaceLocationFlags locationFlags;
	XrPosef pose;
}

// Hand tracker create info (for hand tracking)
struct XrHandTrackerCreateInfoEXT
{
	XrStructureType type;
	void* next;
	XrHandEXT hand;
	XrHandJointSetEXT handJointSet;
}

// Hand joint location
struct XrHandJointLocationEXT
{
	XrSpaceLocationFlags locationFlags;
	XrPosef pose;
	float radius;
}

// Hand joints locate info
struct XrHandJointsLocateInfoEXT
{
	XrStructureType type;
	void* next;
	XrSpace baseSpace;
	XrTime time;
}

// Hand joint locations
struct XrHandJointLocationsEXT
{
	XrStructureType type;
	void* next;
	XrBool32 isActive;
	uint jointCount;
	XrHandJointLocationEXT* jointLocations;
}

// Hand tracking data source info
struct XrHandTrackingDataSourceInfoEXT
{
	XrStructureType type;
	void* next;
	uint requestedDataSourceCount;
	XrHandTrackingDataSourceEXT* requestedDataSources;
}

// Hand tracking data source
typedef XrHandTrackingDataSourceEXT = uint;
const XrHandTrackingDataSourceEXT XR_HAND_TRACKING_DATA_SOURCE_UNOBSTRUCTED_EXT = 1;
const XrHandTrackingDataSourceEXT XR_HAND_TRACKING_DATA_SOURCE_CONTROLLER_EXT = 2;

// Hand tracking data source state
struct XrHandTrackingDataSourceStateEXT
{
	XrStructureType type;
	void* next;
	XrBool32 isActive;
	XrHandTrackingDataSourceEXT dataSource;
}

// System hand tracking properties
struct XrSystemHandTrackingPropertiesEXT
{
	XrStructureType type;
	void* next;
	XrBool32 supportsHandTracking;
}

// Flags (using uint as base type)
typedef XrInstanceCreateFlags = ulong;
typedef XrSessionCreateFlags = ulong;
typedef XrSwapchainCreateFlags = ulong;
typedef XrSwapchainUsageFlags = ulong;
typedef XrCompositionLayerFlags = ulong;
typedef XrViewStateFlags = ulong;
typedef XrSpaceLocationFlags = ulong;

// Flag bits
const XrCompositionLayerFlags XR_COMPOSITION_LAYER_CORRECT_CHROMATIC_ABERRATION_BIT = 0x00000001;
const XrCompositionLayerFlags XR_COMPOSITION_LAYER_BLEND_TEXTURE_SOURCE_ALPHA_BIT = 0x00000002;
const XrCompositionLayerFlags XR_COMPOSITION_LAYER_UNPREMULTIPLIED_ALPHA_BIT = 0x00000004;
const XrViewStateFlags XR_VIEW_STATE_POSITION_VALID_BIT = 0x00000001;
const XrViewStateFlags XR_VIEW_STATE_ORIENTATION_VALID_BIT = 0x00000002;
const XrViewStateFlags XR_VIEW_STATE_POSITION_TRACKED_BIT = 0x00000004;
const XrViewStateFlags XR_VIEW_STATE_ORIENTATION_TRACKED_BIT = 0x00000008;
const XrSpaceLocationFlags XR_SPACE_LOCATION_ORIENTATION_VALID_BIT = 0x00000001;
const XrSpaceLocationFlags XR_SPACE_LOCATION_POSITION_VALID_BIT = 0x00000002;
const XrSpaceLocationFlags XR_SPACE_LOCATION_ORIENTATION_TRACKED_BIT = 0x00000004;
const XrSpaceLocationFlags XR_SPACE_LOCATION_POSITION_TRACKED_BIT = 0x00000008;

// Swapchain usage flags
const XrSwapchainUsageFlags XR_SWAPCHAIN_USAGE_COLOR_ATTACHMENT_BIT = 0x00000001;
const XrSwapchainUsageFlags XR_SWAPCHAIN_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT = 0x00000002;
const XrSwapchainUsageFlags XR_SWAPCHAIN_USAGE_UNORDERED_ACCESS_BIT = 0x00000004;
const XrSwapchainUsageFlags XR_SWAPCHAIN_USAGE_TRANSFER_SRC_BIT = 0x00000008;
const XrSwapchainUsageFlags XR_SWAPCHAIN_USAGE_TRANSFER_DST_BIT = 0x00000010;
const XrSwapchainUsageFlags XR_SWAPCHAIN_USAGE_SAMPLED_BIT = 0x00000020;
const XrSwapchainUsageFlags XR_SWAPCHAIN_USAGE_MUTABLE_FORMAT_BIT = 0x00000040;
const XrSwapchainUsageFlags XR_SWAPCHAIN_USAGE_INPUT_ATTACHMENT_BIT_MND = 0x00000080;

// Version helper functions (converted from macros)
fn uint version_major(XrVersion version) => (uint)((version >> 48) & 0xffffULL);
fn uint version_minor(XrVersion version) => (uint)((version >> 32) & 0xffffULL);
fn uint version_patch(XrVersion version) => (uint)(version & 0xffffffffULL);

// Generic void function pointer (used by xrGetInstanceProcAddr)
alias PFN_xrVoidFunction = fn void();

// xrGetInstanceProcAddr - resolved first via dlsym
alias PfnXrGetInstanceProcAddr = fn XrResult(XrInstance instance, char* name, PFN_xrVoidFunction* function);
PfnXrGetInstanceProcAddr xrGetInstanceProcAddr;

// Core API function pointer types and globals

alias PfnXrEnumerateInstanceExtensionProperties = fn XrResult(
	char* layerName,
	uint propertyCapacityInput,
	uint* propertyCountOutput,
	XrExtensionProperties* properties
);
PfnXrEnumerateInstanceExtensionProperties xrEnumerateInstanceExtensionProperties;

alias PfnXrCreateInstance = fn XrResult(
	XrInstanceCreateInfo* createInfo,
	XrInstance* instance
);
PfnXrCreateInstance xrCreateInstance;

alias PfnXrDestroyInstance = fn XrResult(
	XrInstance instance
);
PfnXrDestroyInstance xrDestroyInstance;

alias PfnXrGetInstanceProperties = fn XrResult(
	XrInstance instance,
	XrInstanceProperties* instanceProperties
);
PfnXrGetInstanceProperties xrGetInstanceProperties;

alias PfnXrEnumerateApiLayerProperties = fn XrResult(
	uint propertyCapacityInput,
	uint* propertyCountOutput,
	void* properties
);
PfnXrEnumerateApiLayerProperties xrEnumerateApiLayerProperties;

alias PfnXrGetSystem = fn XrResult(
	XrInstance instance,
	XrSystemGetInfo* getInfo,
	XrSystemId* systemId
);
PfnXrGetSystem xrGetSystem;

alias PfnXrGetSystemProperties = fn XrResult(
	XrInstance instance,
	XrSystemId systemId,
	XrSystemProperties* properties
);
PfnXrGetSystemProperties xrGetSystemProperties;

alias PfnXrCreateSession = fn XrResult(
	XrInstance instance,
	XrSessionCreateInfo* createInfo,
	XrSession* session
);
PfnXrCreateSession xrCreateSession;

alias PfnXrDestroySession = fn XrResult(
	XrSession session
);
PfnXrDestroySession xrDestroySession;

alias PfnXrBeginSession = fn XrResult(
	XrSession session,
	XrSessionBeginInfo* beginInfo
);
PfnXrBeginSession xrBeginSession;

alias PfnXrEndSession = fn XrResult(
	XrSession session
);
PfnXrEndSession xrEndSession;

alias PfnXrRequestExitSession = fn XrResult(
	XrSession session
);
PfnXrRequestExitSession xrRequestExitSession;

alias PfnXrWaitFrame = fn XrResult(
	XrSession session,
	XrFrameWaitInfo* frameWaitInfo,
	XrFrameState* frameState
);
PfnXrWaitFrame xrWaitFrame;

alias PfnXrBeginFrame = fn XrResult(
	XrSession session,
	XrFrameBeginInfo* frameBeginInfo
);
PfnXrBeginFrame xrBeginFrame;

alias PfnXrEndFrame = fn XrResult(
	XrSession session,
	XrFrameEndInfo* frameEndInfo
);
PfnXrEndFrame xrEndFrame;

alias PfnXrLocateViews = fn XrResult(
	XrSession session,
	XrViewLocateInfo* viewLocateInfo,
	XrViewState* viewState,
	uint viewCapacityInput,
	uint* viewCountOutput,
	XrView* views
);
PfnXrLocateViews xrLocateViews;

alias PfnXrEnumerateViewConfigurations = fn XrResult(
	XrInstance instance,
	XrSystemId systemId,
	uint viewConfigurationTypeCapacityInput,
	uint* viewConfigurationTypeCountOutput,
	XrViewConfigurationType* viewConfigurationTypes
);
PfnXrEnumerateViewConfigurations xrEnumerateViewConfigurations;

alias PfnXrGetViewConfigurationProperties = fn XrResult(
	XrInstance instance,
	XrSystemId systemId,
	XrViewConfigurationType viewConfigurationType,
	void* configurationProperties
);
PfnXrGetViewConfigurationProperties xrGetViewConfigurationProperties;

alias PfnXrEnumerateViewConfigurationViews = fn XrResult(
	XrInstance instance,
	XrSystemId systemId,
	XrViewConfigurationType viewConfigurationType,
	uint viewCapacityInput,
	uint* viewCountOutput,
	XrViewConfigurationView* views
);
PfnXrEnumerateViewConfigurationViews xrEnumerateViewConfigurationViews;

alias PfnXrCreateSwapchain = fn XrResult(
	XrSession session,
	XrSwapchainCreateInfo* createInfo,
	XrSwapchain* swapchain
);
PfnXrCreateSwapchain xrCreateSwapchain;

alias PfnXrDestroySwapchain = fn XrResult(
	XrSwapchain swapchain
);
PfnXrDestroySwapchain xrDestroySwapchain;

alias PfnXrEnumerateSwapchainImages = fn XrResult(
	XrSwapchain swapchain,
	uint imageCapacityInput,
	uint* imageCountOutput,
	void* images
);
PfnXrEnumerateSwapchainImages xrEnumerateSwapchainImages;

alias PfnXrAcquireSwapchainImage = fn XrResult(
	XrSwapchain swapchain,
	void* acquireInfo,
	uint* index
);
PfnXrAcquireSwapchainImage xrAcquireSwapchainImage;

alias PfnXrWaitSwapchainImage = fn XrResult(
	XrSwapchain swapchain,
	void* waitInfo
);
PfnXrWaitSwapchainImage xrWaitSwapchainImage;

alias PfnXrReleaseSwapchainImage = fn XrResult(
	XrSwapchain swapchain,
	void* releaseInfo
);
PfnXrReleaseSwapchainImage xrReleaseSwapchainImage;

alias PfnXrCreateReferenceSpace = fn XrResult(
	XrSession session,
	XrReferenceSpaceCreateInfo* createInfo,
	XrSpace* space
);
PfnXrCreateReferenceSpace xrCreateReferenceSpace;

alias PfnXrGetReferenceSpaceBoundsRect = fn XrResult(
	XrSession session,
	XrReferenceSpaceType referenceSpaceType,
	void* bounds
);
PfnXrGetReferenceSpaceBoundsRect xrGetReferenceSpaceBoundsRect;

alias PfnXrDestroySpace = fn XrResult(
	XrSpace space
);
PfnXrDestroySpace xrDestroySpace;

alias PfnXrLocateSpace = fn XrResult(
	XrSpace space,
	XrSpace baseSpace,
	XrTime time,
	XrSpaceLocation* location
);
PfnXrLocateSpace xrLocateSpace;

alias PfnXrPollEvent = fn XrResult(
	XrInstance instance,
	XrEventDataBuffer* eventData
);
PfnXrPollEvent xrPollEvent;

alias PfnXrStringToPath = fn XrResult(
	XrInstance instance,
	char* pathString,
	XrPath* path
);
PfnXrStringToPath xrStringToPath;

alias PfnXrPathToString = fn XrResult(
	XrInstance instance,
	XrPath path,
	uint bufferCapacityInput,
	uint* bufferCountOutput,
	char* buffer
);
PfnXrPathToString xrPathToString;

// Vulkan KHR extension function pointer types and globals

alias PfnXrGetVulkanGraphicsRequirementsKHR = fn XrResult(
	XrInstance instance,
	XrSystemId systemId,
	XrGraphicsRequirementsVulkanKHR* graphicsRequirements
);
PfnXrGetVulkanGraphicsRequirementsKHR xrGetVulkanGraphicsRequirementsKHR;

alias PfnXrGetVulkanInstanceExtensionsKHR = fn XrResult(
	XrInstance instance,
	XrSystemId systemId,
	uint bufferCapacityInput,
	uint* bufferCountOutput,
	char* buffer
);
PfnXrGetVulkanInstanceExtensionsKHR xrGetVulkanInstanceExtensionsKHR;

alias PfnXrGetVulkanDeviceExtensionsKHR = fn XrResult(
	XrInstance instance,
	XrSystemId systemId,
	uint bufferCapacityInput,
	uint* bufferCountOutput,
	char* buffer
);
PfnXrGetVulkanDeviceExtensionsKHR xrGetVulkanDeviceExtensionsKHR;

alias PfnXrGetVulkanGraphicsDeviceKHR = fn XrResult(
	XrInstance instance,
	XrSystemId systemId,
	void* vkInstance,
	void** vkPhysicalDevice
);
PfnXrGetVulkanGraphicsDeviceKHR xrGetVulkanGraphicsDeviceKHR;

// Hand tracking extension function pointer types and globals

alias PfnXrCreateHandTrackerEXT = fn XrResult(
	XrSession session,
	XrHandTrackerCreateInfoEXT* createInfo,
	XrHandTrackerEXT* handTracker
);
PfnXrCreateHandTrackerEXT xrCreateHandTrackerEXT;

alias PfnXrDestroyHandTrackerEXT = fn XrResult(
	XrHandTrackerEXT handTracker
);
PfnXrDestroyHandTrackerEXT xrDestroyHandTrackerEXT;

alias PfnXrLocateHandJointsEXT = fn XrResult(
	XrHandTrackerEXT handTracker,
	XrHandJointsLocateInfoEXT* locateInfo,
	XrHandJointLocationsEXT* locations
);
PfnXrLocateHandJointsEXT xrLocateHandJointsEXT;

// Error handling helpers
fn char* result_to_string(XrResult result)
{
	switch (result)
	{
		case XR_SUCCESS: return "XR_SUCCESS";
		case XR_TIMEOUT_EXPIRED: return "XR_TIMEOUT_EXPIRED";
		case XR_SESSION_LOSS_PENDING: return "XR_SESSION_LOSS_PENDING";
		case XR_EVENT_UNAVAILABLE: return "XR_EVENT_UNAVAILABLE";
		case XR_SPACE_BOUNDS_UNAVAILABLE: return "XR_SPACE_BOUNDS_UNAVAILABLE";
		case XR_SESSION_NOT_FOCUSED: return "XR_SESSION_NOT_FOCUSED";
		case XR_FRAME_DISCARDED: return "XR_FRAME_DISCARDED";
		case XR_ERROR_VALIDATION_FAILURE: return "XR_ERROR_VALIDATION_FAILURE";
		case XR_ERROR_RUNTIME_FAILURE: return "XR_ERROR_RUNTIME_FAILURE";
		case XR_ERROR_OUT_OF_MEMORY: return "XR_ERROR_OUT_OF_MEMORY";
		case XR_ERROR_API_VERSION_UNSUPPORTED: return "XR_ERROR_API_VERSION_UNSUPPORTED";
		case XR_ERROR_INITIALIZATION_FAILED: return "XR_ERROR_INITIALIZATION_FAILED";
		case XR_ERROR_FUNCTION_UNSUPPORTED: return "XR_ERROR_FUNCTION_UNSUPPORTED";
		case XR_ERROR_FEATURE_UNSUPPORTED: return "XR_ERROR_FEATURE_UNSUPPORTED";
		case XR_ERROR_EXTENSION_NOT_PRESENT: return "XR_ERROR_EXTENSION_NOT_PRESENT";
		case XR_ERROR_LIMIT_REACHED: return "XR_ERROR_LIMIT_REACHED";
		case XR_ERROR_SIZE_INSUFFICIENT: return "XR_ERROR_SIZE_INSUFFICIENT";
		case XR_ERROR_HANDLE_INVALID: return "XR_ERROR_HANDLE_INVALID";
		case XR_ERROR_INSTANCE_LOST: return "XR_ERROR_INSTANCE_LOST";
		case XR_ERROR_SESSION_RUNNING: return "XR_ERROR_SESSION_RUNNING";
		case XR_ERROR_SESSION_NOT_RUNNING: return "XR_ERROR_SESSION_NOT_RUNNING";
		case XR_ERROR_SESSION_LOST: return "XR_ERROR_SESSION_LOST";
		case XR_ERROR_SYSTEM_INVALID: return "XR_ERROR_SYSTEM_INVALID";
		case XR_ERROR_PATH_INVALID: return "XR_ERROR_PATH_INVALID";
		case XR_ERROR_TIME_INVALID: return "XR_ERROR_TIME_INVALID";
		case XR_ERROR_REFERENCE_SPACE_UNSUPPORTED: return "XR_ERROR_REFERENCE_SPACE_UNSUPPORTED";
		case XR_ERROR_GRAPHICS_DEVICE_INVALID: return "XR_ERROR_GRAPHICS_DEVICE_INVALID";
		case XR_ERROR_POSE_INVALID: return "XR_ERROR_POSE_INVALID";
		default: return "Unknown XR error";
	}
}

fn void check(XrResult result, char* operation)
{
	if (failed(result))
	{
		io::printfn("OpenXR Error during %s: %s (%d)", operation, result_to_string(result), result);
	}
}
