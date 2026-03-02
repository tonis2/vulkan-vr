[shader("vertex")]
float4 vertexMain(uint vertexID : SV_VertexID) : SV_Position
{
    // Full screen triangle
    float2 pos = float2(
        (vertexID == 2) ? 3.0 : -1.0,
        (vertexID == 0) ? -3.0 : 1.0
    );
    return float4(pos, 0.0, 1.0);
}

[shader("fragment")]
float4 fragmentMain() : SV_Target
{
    // Simple gradient for testing
    return float4(0.2, 0.4, 0.8, 1.0);
}
