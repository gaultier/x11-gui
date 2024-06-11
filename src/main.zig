const std = @import("std");

fn handshake(stream: *std.net.Stream) !void {
    const authorization = "MIT-MAGIC-COOKIE-1";
    const Request = packed struct {
        endianness: u8 = 'l',
        pad1: u8 = 0,
        major_version: u16 = 11,
        minor_version: u16 = 0,
        authorization_len: u16 = authorization.len,
        authorization_data_len: u16 = 16,
        pad2: u16 = 0,
    };
    comptime std.debug.assert(@sizeOf(Request) == 12);
    var req = Request{};
    try stream.writeAll(std.mem.asBytes(&req));
    try stream.writeAll(std.mem.asBytes(&authorization));
    try stream.writeAll(std.mem.asBytes(&[2]u8{ 0, 0 }));
    const cookie = [16]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    try stream.writeAll(std.mem.asBytes(&cookie));

    const Response = packed struct {
        success: bool,
        pad1: u8,
        major_version: u16,
        minor_version: u16,
        length: u16,
        release_number: u32,
        resource_id_base: u32,
        resource_id_mask: u32,
        motion_buffer_size: u32,
        vendor_length: u16,
        maximum_request_length: u16,
        screens_in_root_count: u8,
        formats_count: u8,
        image_byte_order: u8,
        bitmap_format_bit_order: u8,
        bitmap_format_scanline_unit: u8,
        bitmap_format_scanline_pad: u8,
        min_keycode: u8,
        max_keycode: u8,
        pad2: u32,
    };
    var read_buffer = [_]u8{0} ** (1 << 15);
    const n_read = try stream.readAtLeast(&read_buffer, @sizeOf(Response));

    const response: Response = std.mem.bytesToValue(Response, read_buffer[0..n_read]);
    std.debug.print("{}", .{response});
}

pub fn main() !void {
    var socket = try std.net.connectUnixSocket("/tmp/.X11-unix/X0");
    try handshake(&socket);
}
