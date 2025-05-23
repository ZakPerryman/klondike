package SliceUI

import rl "vendor:raylib"
import "core:math"

Rect :: struct {
    x, y, w, h: f32
}

SliceFunc :: #type proc(rect: ^Rect, amount: f32) -> Rect
DecorateFunc :: #type proc(rect: Rect, amount: f32) -> Rect

slice_top :: proc(rect: ^Rect, amount: f32) -> Rect {
    // assert(rect.h >= amount)
    
    rect.y += amount
    rect.h -= amount

    return Rect{
        rect.x, rect.y - amount, rect.w, amount
    }
}

slice_bottom :: proc(rect: ^Rect, amount: f32) -> Rect {
    // assert(rect.h >= amount)
    
    rect.h -= amount
    
    return Rect{
        rect.x, rect.y + (rect.h), rect.w, amount
    }
}

slice_left :: proc(rect: ^Rect, amount: f32) -> Rect {
    // assert(rect.w >= amount)

    rect.x += amount
    rect.w -= amount

    return Rect{
        rect.x - amount, rect.y, amount, rect.h
    }
}

slice_right :: proc(rect: ^Rect, amount: f32) -> Rect {
    // assert(rect.w >= amount)

    rect.w -= amount

    return Rect{
        rect.x + (rect.w), rect.y, amount, rect.h
    }
}

slice_series :: proc(rect: ^Rect, sliceFunc: SliceFunc, amount: f32, count: int) -> []Rect {
    returnSlice := make([]Rect, count)
    
    for num in 0..<count {
        returnSlice[num] = sliceFunc(rect, amount)
    }

    return returnSlice
}

// Decorator, doesn't act on the parent rect.
decorate_pad :: proc(rect: Rect, amount: f32) -> Rect {
    // assert(rect.w >= amount && rect.h >= amount)

    return Rect{
        rect.x + amount, rect.y + amount, rect.w - amount * 2, rect.h - amount * 2
    }
}

decorate_pad_height :: proc(rect: Rect, amount: f32) -> Rect {
    return Rect{
        rect.x, rect.y + amount, rect.w, rect.h - amount * 2
    }
}

decorate_pad_width :: proc(rect: Rect, amount: f32) -> Rect {
    return Rect{
        rect.x + amount, rect.y, rect.w - amount * 2, rect.h
    }
}

// Renderer
render_rectangle :: proc(rect: Rect, color: rl.Color) {
    rl.DrawRectangleRec(transmute(rl.Rectangle)rect, color)
}

render_rounded_rectangle :: proc(rect: Rect, corner: f32, color: rl.Color) {
    rl.DrawRectangleRounded(transmute(rl.Rectangle)rect, corner, 8, color)
}

render_center_text :: proc(text: cstring, textSize: f32, rect: Rect, textColor: rl.Color = rl.BLACK) {
    font := rl.GetFontDefault()
    textLength := rl.MeasureTextEx(font, text, textSize, 2)
    rl.DrawTextPro(
        font,
        text,
        {rect.x + rect.w / 2 - textLength.x / 2,
        rect.y + rect.h / 2 - textLength.y / 2},
        {},
        0,
        textSize,
        2,
        textColor
    )
}

render_texture_centered :: proc(texture: rl.Texture2D, rect: Rect, tint: rl.Color = rl.WHITE) {
    rl.DrawTexture(texture, cast(i32)(math.floor(rect.x - cast(f32)(texture.width / 2)) + rect.w / 2), cast(i32)(math.floor(rect.y - cast(f32)(texture.height / 2)) + rect.h / 2), tint)
}

render_texture_section_centered :: proc(texture: rl.Texture2D, source: rl.Rectangle, rect: Rect, tint: rl.Color = rl.WHITE) {
    rl.DrawTextureRec(texture, source, {
        (math.floor(rect.x - cast(f32)(source.width / 2)) + rect.w / 2),
        (math.floor(rect.y - cast(f32)(source.height / 2)) + rect.h / 2)
    }, tint)
}