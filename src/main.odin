package main

import rl "vendor:raylib"

import "core:fmt"
import "core:math"
import "core:math/rand"

import "./slice"

import table "core:slice"

PROJECT_NAME :: "Template"

Cards :: enum {
    SPADE_A,
    SPADE_2,
    SPADE_3,
    SPADE_4,
    SPADE_5,
    SPADE_6,
    SPADE_7,
    SPADE_8,
    SPADE_9,
    SPADE_10,
    SPADE_J,
    SPADE_Q,
    SPADE_K,

    CLUB_A,
    CLUB_2,
    CLUB_3,
    CLUB_4,
    CLUB_5,
    CLUB_6,
    CLUB_7,
    CLUB_8,
    CLUB_9,
    CLUB_10,
    CLUB_J,
    CLUB_Q,
    CLUB_K,

    HEART_A,
    HEART_2,
    HEART_3,
    HEART_4,
    HEART_5,
    HEART_6,
    HEART_7,
    HEART_8,
    HEART_9,
    HEART_10,
    HEART_J,
    HEART_Q,
    HEART_K,

    DIAMOND_A,
    DIAMOND_2,
    DIAMOND_3,
    DIAMOND_4,
    DIAMOND_5,
    DIAMOND_6,
    DIAMOND_7,
    DIAMOND_8,
    DIAMOND_9,
    DIAMOND_10,
    DIAMOND_J,
    DIAMOND_Q,
    DIAMOND_K,
}

CardSuites :: enum {
    HEARTS,
    DIAMONDS,
    SPADES,
    CLUBS,
}

CardValues :: enum int {
    ACE = 1,
    TWO,
    THREE,
    FOUR,
    FIVE,
    SIX,
    SEVEN,
    EIGHT,
    NINE,
    TEN,
    JACK,
    QUEEN,
    KING,
}

CardData :: struct {
    suite: CardSuites,
    cardValue: CardValues,
    hidden: bool,
}

GameState :: struct {
    clearBackground: rl.Color,
    deck: [52]CardData,
    playDeck: [dynamic]CardData,

    handCards: [dynamic]CardData,
    handColumnIndex: int,

    columns: [7][dynamic]CardData,
    tableu: [4][dynamic]CardData,

    clearDelay: f32
}

InterfaceStates :: enum {
    MAIN_MENU,
    OPTIONS_MENU,
    GAME,
    PAUSE,
    END_SCREEN,
}

AppState := struct {
    currentInterface: InterfaceStates,
    shouldQuit : bool,
    gameState : GameState,
}{
    currentInterface = .MAIN_MENU,
}

CardBack : rl.Texture2D
CardTextures : [Cards]rl.Texture2D

MenuSounds : []rl.Sound

CardShuffle : rl.Sound 

CardDraw : []rl.Sound

main :: proc() {
    rl.InitWindow(0, 0, PROJECT_NAME)
    rl.InitAudioDevice()

    CardBack = rl.LoadTexture("assets/gfx/card_back.png")

    CardTextures = {
        .CLUB_2 = rl.LoadTexture("assets/gfx/card_clubs_02.png"),
        .CLUB_3 = rl.LoadTexture("assets/gfx/card_clubs_03.png"),
        .CLUB_4 = rl.LoadTexture("assets/gfx/card_clubs_04.png"),
        .CLUB_5 = rl.LoadTexture("assets/gfx/card_clubs_05.png"),
        .CLUB_6 = rl.LoadTexture("assets/gfx/card_clubs_06.png"),
        .CLUB_7 = rl.LoadTexture("assets/gfx/card_clubs_07.png"),
        .CLUB_8 = rl.LoadTexture("assets/gfx/card_clubs_08.png"),
        .CLUB_9 = rl.LoadTexture("assets/gfx/card_clubs_09.png"),
        .CLUB_10 = rl.LoadTexture("assets/gfx/card_clubs_10.png"),
        .CLUB_A = rl.LoadTexture("assets/gfx/card_clubs_A.png"),
        .CLUB_J = rl.LoadTexture("assets/gfx/card_clubs_J.png"),
        .CLUB_Q = rl.LoadTexture("assets/gfx/card_clubs_Q.png"),
        .CLUB_K = rl.LoadTexture("assets/gfx/card_clubs_K.png"),

        .SPADE_2 = rl.LoadTexture("assets/gfx/card_spades_02.png"),
        .SPADE_3 = rl.LoadTexture("assets/gfx/card_spades_03.png"),
        .SPADE_4 = rl.LoadTexture("assets/gfx/card_spades_04.png"),
        .SPADE_5 = rl.LoadTexture("assets/gfx/card_spades_05.png"),
        .SPADE_6 = rl.LoadTexture("assets/gfx/card_spades_06.png"),
        .SPADE_7 = rl.LoadTexture("assets/gfx/card_spades_07.png"),
        .SPADE_8 = rl.LoadTexture("assets/gfx/card_spades_08.png"),
        .SPADE_9 = rl.LoadTexture("assets/gfx/card_spades_09.png"),
        .SPADE_10 = rl.LoadTexture("assets/gfx/card_spades_10.png"),
        .SPADE_A = rl.LoadTexture("assets/gfx/card_spades_A.png"),
        .SPADE_J = rl.LoadTexture("assets/gfx/card_spades_J.png"),
        .SPADE_Q = rl.LoadTexture("assets/gfx/card_spades_Q.png"),
        .SPADE_K = rl.LoadTexture("assets/gfx/card_spades_K.png"),

        .HEART_2 = rl.LoadTexture("assets/gfx/card_hearts_02.png"),
        .HEART_3 = rl.LoadTexture("assets/gfx/card_hearts_03.png"),
        .HEART_4 = rl.LoadTexture("assets/gfx/card_hearts_04.png"),
        .HEART_5 = rl.LoadTexture("assets/gfx/card_hearts_05.png"),
        .HEART_6 = rl.LoadTexture("assets/gfx/card_hearts_06.png"),
        .HEART_7 = rl.LoadTexture("assets/gfx/card_hearts_07.png"),
        .HEART_8 = rl.LoadTexture("assets/gfx/card_hearts_08.png"),
        .HEART_9 = rl.LoadTexture("assets/gfx/card_hearts_09.png"),
        .HEART_10 = rl.LoadTexture("assets/gfx/card_hearts_10.png"),
        .HEART_A = rl.LoadTexture("assets/gfx/card_hearts_A.png"),
        .HEART_J = rl.LoadTexture("assets/gfx/card_hearts_J.png"),
        .HEART_Q = rl.LoadTexture("assets/gfx/card_hearts_Q.png"),
        .HEART_K = rl.LoadTexture("assets/gfx/card_hearts_K.png"),

        .DIAMOND_2 = rl.LoadTexture("assets/gfx/card_diamonds_02.png"),
        .DIAMOND_3 = rl.LoadTexture("assets/gfx/card_diamonds_03.png"),
        .DIAMOND_4 = rl.LoadTexture("assets/gfx/card_diamonds_04.png"),
        .DIAMOND_5 = rl.LoadTexture("assets/gfx/card_diamonds_05.png"),
        .DIAMOND_6 = rl.LoadTexture("assets/gfx/card_diamonds_06.png"),
        .DIAMOND_7 = rl.LoadTexture("assets/gfx/card_diamonds_07.png"),
        .DIAMOND_8 = rl.LoadTexture("assets/gfx/card_diamonds_08.png"),
        .DIAMOND_9 = rl.LoadTexture("assets/gfx/card_diamonds_09.png"),
        .DIAMOND_10 = rl.LoadTexture("assets/gfx/card_diamonds_10.png"),
        .DIAMOND_A = rl.LoadTexture("assets/gfx/card_diamonds_A.png"),
        .DIAMOND_J = rl.LoadTexture("assets/gfx/card_diamonds_J.png"),
        .DIAMOND_Q = rl.LoadTexture("assets/gfx/card_diamonds_Q.png"),
        .DIAMOND_K = rl.LoadTexture("assets/gfx/card_diamonds_K.png"),
    }

    MenuSounds = {
        rl.LoadSound("assets/sfx/chips-collide-1.ogg"),
        rl.LoadSound("assets/sfx/chips-collide-2.ogg"),
        rl.LoadSound("assets/sfx/chips-collide-3.ogg"),
        rl.LoadSound("assets/sfx/chips-collide-4.ogg")
    }

    CardShuffle = rl.LoadSound("assets/sfx/card-shuffle.ogg")

    CardDraw = {
        rl.LoadSound("assets/sfx/card-slide-1.ogg"),
        rl.LoadSound("assets/sfx/card-slide-2.ogg"),
        rl.LoadSound("assets/sfx/card-slide-3.ogg"),
        rl.LoadSound("assets/sfx/card-slide-4.ogg"),
        rl.LoadSound("assets/sfx/card-slide-5.ogg"),
        rl.LoadSound("assets/sfx/card-slide-6.ogg"),
        rl.LoadSound("assets/sfx/card-slide-7.ogg"),
        rl.LoadSound("assets/sfx/card-slide-8.ogg"),
    }

    rl.ToggleFullscreen()
    rl.SetExitKey(.KEY_NULL)

    for(!rl.WindowShouldClose() && !AppState.shouldQuit) {
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLANK)

        if(rl.IsKeyDown(.W)) {
            rl.PlaySound(CardShuffle)
        }

        switch(AppState.currentInterface) {
            case .MAIN_MENU:
                mainMenuProcess()
            case .OPTIONS_MENU:
                optionsMenuProcess()
            case .GAME:
                gameProcess()
            case .PAUSE:
                pauseProcess()
            case .END_SCREEN:
                endProcess()
        }

        rl.EndDrawing()
    }

    rl.CloseWindow()
}

MENU_SOUND_COUNTER : int = 0
play_menu_sound :: proc() {
    rl.PlaySound(MenuSounds[MENU_SOUND_COUNTER])
    MENU_SOUND_COUNTER += 1
    MENU_SOUND_COUNTER %= len(MenuSounds)
}

mainMenuProcess :: proc() {
    menuRect := slice.Rect{
        0,
        0,
        cast(f32)rl.GetRenderWidth(),
        cast(f32)rl.GetRenderHeight(),
    }

    menuRect = slice.decorate_pad(menuRect, cast(f32)rl.GetRenderHeight() * 0.1)
    menuRect = slice.decorate_pad_width(menuRect, cast(f32)rl.GetRenderWidth() * 0.4)

    menuButtonStart := slice.slice_top(&menuRect, 32)
    menuStartColor := rl.WHITE
    if(rl.CheckCollisionPointRec(rl.GetMousePosition(), transmute(rl.Rectangle)menuButtonStart)) {
        menuStartColor = rl.YELLOW
        if(!rl.CheckCollisionPointRec(rl.GetMousePosition() - rl.GetMouseDelta(), transmute(rl.Rectangle)menuButtonStart)) {
            play_menu_sound()
        }

        if(rl.IsMouseButtonDown(.LEFT)) {
            menuStartColor = rl.BLUE
        }
        if(rl.IsMouseButtonReleased(.LEFT)) {
            AppState.gameState = GameState{}
            initializeGame(&AppState.gameState)
            AppState.currentInterface = .GAME
        }
    }
    slice.render_rectangle(menuButtonStart, menuStartColor)
    slice.render_center_text("Start", 24, menuButtonStart)

    menuButtonOptions := slice.slice_top(&menuRect, 32)
    menuOptionColor := rl.WHITE
    if(rl.CheckCollisionPointRec(rl.GetMousePosition(), transmute(rl.Rectangle)menuButtonOptions)) {
        menuOptionColor = rl.YELLOW
        if(!rl.CheckCollisionPointRec(rl.GetMousePosition() - rl.GetMouseDelta(), transmute(rl.Rectangle)menuButtonOptions)) {
            play_menu_sound()
        }

        if(rl.IsMouseButtonDown(.LEFT)) {
            menuOptionColor = rl.BLUE
        }
        if(rl.IsMouseButtonReleased(.LEFT)) {
            AppState.currentInterface = .OPTIONS_MENU
        }
    }
    slice.render_rectangle(menuButtonOptions, menuOptionColor)
    slice.render_center_text("Options", 24, menuButtonOptions)

    menuButtonQuit := slice.slice_bottom(&menuRect, 32)
    menuQuitColor := rl.WHITE
    if(rl.CheckCollisionPointRec(rl.GetMousePosition(), transmute(rl.Rectangle)menuButtonQuit)) {
        menuQuitColor = rl.YELLOW
        if(!rl.CheckCollisionPointRec(rl.GetMousePosition() - rl.GetMouseDelta(), transmute(rl.Rectangle)menuButtonQuit)) {
            play_menu_sound()
        }

        if(rl.IsMouseButtonDown(.LEFT)) {
            menuQuitColor = rl.BLUE
        }
        if(rl.IsMouseButtonReleased(.LEFT)) {
            AppState.shouldQuit = true
        }
    }
    slice.render_rectangle(menuButtonQuit, menuQuitColor)
    slice.render_center_text("Quit", 24, menuButtonQuit)
}

optionsMenuProcess :: proc() {
    menuRect := slice.Rect{
        0,
        0,
        cast(f32)rl.GetRenderWidth(),
        cast(f32)rl.GetRenderHeight(),
    }

    menuRect = slice.decorate_pad(menuRect, cast(f32)rl.GetRenderHeight() * 0.1)
    menuRect = slice.decorate_pad_width(menuRect, cast(f32)rl.GetRenderWidth() * 0.4)

    menuOptionBack := slice.slice_bottom(&menuRect, 32)
    menuBackColor := rl.WHITE
    if(rl.CheckCollisionPointRec(rl.GetMousePosition(), transmute(rl.Rectangle)menuOptionBack)) {
        menuBackColor = rl.YELLOW
        if(!rl.CheckCollisionPointRec(rl.GetMousePosition() - rl.GetMouseDelta(), transmute(rl.Rectangle)menuOptionBack)) {
            play_menu_sound()
        }
        if(rl.IsMouseButtonDown(.LEFT)) {
            menuBackColor = rl.BLUE
        }
        if(rl.IsMouseButtonReleased(.LEFT)) {
            AppState.currentInterface = .MAIN_MENU
        }
    }
    slice.render_rectangle(menuOptionBack, menuBackColor)
    slice.render_center_text("Back", 24, menuOptionBack)
}

initializeGame :: proc(gameState: ^GameState) {
    gameState.clearBackground = transmute(rl.Color)rand.uint32()

    gameState.handColumnIndex = -1

    gameState.deck = {
        CardData{ .HEARTS, .ACE, true },
        CardData{ .HEARTS, .TWO, true },
        CardData{ .HEARTS, .THREE, true },
        CardData{ .HEARTS, .FOUR, true },
        CardData{ .HEARTS, .FIVE, true },
        CardData{ .HEARTS, .SIX, true },
        CardData{ .HEARTS, .SEVEN, true },
        CardData{ .HEARTS, .EIGHT, true },
        CardData{ .HEARTS, .NINE, true },
        CardData{ .HEARTS, .TEN, true },
        CardData{ .HEARTS, .JACK, true },
        CardData{ .HEARTS, .QUEEN, true },
        CardData{ .HEARTS, .KING, true },

        CardData{ .SPADES, .ACE, true },
        CardData{ .SPADES, .TWO, true },
        CardData{ .SPADES, .THREE, true },
        CardData{ .SPADES, .FOUR, true },
        CardData{ .SPADES, .FIVE, true },
        CardData{ .SPADES, .SIX, true },
        CardData{ .SPADES, .SEVEN, true },
        CardData{ .SPADES, .EIGHT, true },
        CardData{ .SPADES, .NINE, true },
        CardData{ .SPADES, .TEN, true },
        CardData{ .SPADES, .JACK, true },
        CardData{ .SPADES, .QUEEN, true },
        CardData{ .SPADES, .KING, true },

        CardData{ .DIAMONDS, .ACE, true },
        CardData{ .DIAMONDS, .TWO, true },
        CardData{ .DIAMONDS, .THREE, true },
        CardData{ .DIAMONDS, .FOUR, true },
        CardData{ .DIAMONDS, .FIVE, true },
        CardData{ .DIAMONDS, .SIX, true },
        CardData{ .DIAMONDS, .SEVEN, true },
        CardData{ .DIAMONDS, .EIGHT, true },
        CardData{ .DIAMONDS, .NINE, true },
        CardData{ .DIAMONDS, .TEN, true },
        CardData{ .DIAMONDS, .JACK, true },
        CardData{ .DIAMONDS, .QUEEN, true },
        CardData{ .DIAMONDS, .KING, true },

        CardData{ .CLUBS, .ACE, true },
        CardData{ .CLUBS, .TWO, true },
        CardData{ .CLUBS, .THREE, true },
        CardData{ .CLUBS, .FOUR, true },
        CardData{ .CLUBS, .FIVE, true },
        CardData{ .CLUBS, .SIX, true },
        CardData{ .CLUBS, .SEVEN, true },
        CardData{ .CLUBS, .EIGHT, true },
        CardData{ .CLUBS, .NINE, true },
        CardData{ .CLUBS, .TEN, true },
        CardData{ .CLUBS, .JACK, true },
        CardData{ .CLUBS, .QUEEN, true },
        CardData{ .CLUBS, .KING, true },
    }

    rand.shuffle(gameState.deck[:])

    for card in gameState.deck {
        append(&gameState.playDeck, card)
    }

    for cardStack, idx in gameState.columns {
        for i in 0..=idx {
            append(&gameState.columns[idx], gameState.playDeck[0])
            ordered_remove(&gameState.playDeck, 0)
            
            if(i == idx) {
                gameState.columns[idx][i].hidden = false
            }
        }
    }
}

gameProcess :: proc() {
    rl.ClearBackground(AppState.gameState.clearBackground)

    if(rl.IsKeyPressed(.ESCAPE)) {
        AppState.currentInterface = .PAUSE
        return
    }

    if(len(AppState.gameState.playDeck) > 0) {
        rl.DrawTexture(CardTextures[getCardDataTexture(AppState.gameState.playDeck[0])], 0, 16, rl.WHITE)
    } else {
        rl.DrawTexture(CardBack, 0, 16, rl.WHITE)
    }

    // Return logic
    if(rl.IsMouseButtonPressed(.RIGHT) && AppState.gameState.handColumnIndex != -1) {
        if(AppState.gameState.handColumnIndex <= -3) {
            tableuIndex := math.abs(AppState.gameState.handColumnIndex) - 3
            append(&AppState.gameState.tableu[tableuIndex], AppState.gameState.handCards[0])
            clear_dynamic_array(&AppState.gameState.handCards)
            AppState.gameState.handColumnIndex = -1
        }
        if(AppState.gameState.handColumnIndex == -2) {
            inject_at(&AppState.gameState.playDeck, 0, AppState.gameState.handCards[0])
            clear_dynamic_array(&AppState.gameState.handCards)
            AppState.gameState.handColumnIndex = -1
        }
        else
        {
            #reverse for card, cIdx in AppState.gameState.handCards {
                append(&AppState.gameState.columns[AppState.gameState.handColumnIndex], card)
            }
            clear_dynamic_array(&AppState.gameState.handCards)
            AppState.gameState.handColumnIndex = -1
        }

    }

    // Deck handling logic
    if(len(AppState.gameState.playDeck) > 0 && len(AppState.gameState.handCards) == 0) {
        if(rl.CheckCollisionPointRec(rl.GetMousePosition(), rl.Rectangle{
            cast(f32)(0 + 11),
            cast(f32)(32 + 2),
            42,
            60
        })) {
            if(rl.IsMouseButtonPressed(.LEFT)){
                append(&AppState.gameState.handCards, AppState.gameState.playDeck[0])
                ordered_remove(&AppState.gameState.playDeck, 0)
                AppState.gameState.handColumnIndex = -2
            }
            if(rl.IsMouseButtonPressed(.RIGHT)){
                card := AppState.gameState.playDeck[0]
                append(&AppState.gameState.playDeck, card)
                ordered_remove(&AppState.gameState.playDeck, 0)
            }
        }
    }

    // Column Draw Processing Block
    for &cardStack, idx in AppState.gameState.columns {
        stackX : i32 = 48 * cast(i32)idx + 48
        
        if(len(cardStack) == 0) {
            rl.DrawTexture(CardBack, stackX, 32, rl.WHITE)
        }

        for card, cIdx in cardStack {
            if(card.hidden) {
                rl.DrawTexture(CardBack, stackX, cast(i32)cIdx * 16 + 32, rl.WHITE)
            } else {
                rl.DrawTexture(CardTextures[getCardDataTexture(card)], stackX, cast(i32)cIdx * 16 + 32, rl.WHITE)
            }
        }
    }

    // Column Logic Processing Block
    for &cardStack, idx in AppState.gameState.columns {
        stackX : i32 = 48 * cast(i32)idx + 48

        if(len(cardStack) == 0) {
            if(rl.CheckCollisionPointRec(rl.GetMousePosition(), rl.Rectangle{
                cast(f32)(stackX + 11),
                cast(f32)(32 + 2),
                42,
                60
            })) {
                if(rl.IsMouseButtonPressed(.LEFT)) {
                    if(len(AppState.gameState.handCards) > 0) {
                        #reverse for handCard, handIdx in AppState.gameState.handCards {
                            append(&cardStack, handCard)
                        }
                        clear_dynamic_array(&AppState.gameState.handCards)
                        AppState.gameState.handColumnIndex = -1
                    }
                }
                continue
            }
        }

        #reverse for card, cIdx in cardStack {
            if(rl.CheckCollisionPointRec(rl.GetMousePosition(), rl.Rectangle{
                cast(f32)(stackX + 11),
                cast(f32)((cast(i32)cIdx * 16 + 32) + 2),
                42,
                60
            })) {
                if(rl.IsMouseButtonPressed(.LEFT)) {
                    if(len(AppState.gameState.handCards) > 0) {
                        if(canStackColumn(AppState.gameState.handCards[:], cardStack[:])) {
                            #reverse for handCard, handIdx in AppState.gameState.handCards {
                                append(&cardStack, handCard)
                            }
                            clear_dynamic_array(&AppState.gameState.handCards)
                            AppState.gameState.handColumnIndex = -1
                        }
                    } else {
                        if(cIdx != len(cardStack) - 1) {
                            if(isStackValid(cardStack[cIdx:len(cardStack)])) {
                                AppState.gameState.handColumnIndex = idx
                                if(cIdx > 0) {
                                    cardStack[cIdx - 1].hidden = false
                                }
                                for newHandCardIdx := len(cardStack) - 1; newHandCardIdx >= cIdx; newHandCardIdx -= 1 {
                                    append(&AppState.gameState.handCards, cardStack[newHandCardIdx])
                                    ordered_remove(&cardStack, newHandCardIdx)
                                }
                            }
                        } else {
                            if(cIdx > 0) {
                                cardStack[cIdx - 1].hidden = false
                            }
                            AppState.gameState.handColumnIndex = idx
                            append(&AppState.gameState.handCards, card)
                            ordered_remove(&cardStack, cIdx)
                        }
                    }
                    break
                }
            }
        }
    }

    // Tableu Draw Processing Block
    for cardStack, idx in AppState.gameState.tableu {
        stackX : i32 = 48 * cast(i32)idx + 48 * 8
        if(len(cardStack) == 0) {
            rl.DrawTexture(CardBack, stackX, 16, rl.WHITE)
        } else {
            card := cardStack[len(cardStack) - 1]
            rl.DrawTexture(CardTextures[getCardDataTexture(card)], stackX, 16, rl.WHITE)
        }
    }

    // Tableu Logic Processing Block
    for &cardStack, idx in AppState.gameState.tableu {
        stackX : i32 = 48 * cast(i32)idx + 48 * 8

        if(rl.CheckCollisionPointRec(rl.GetMousePosition(), rl.Rectangle{
                cast(f32)(stackX + 11),
                cast(f32)(32 + 2),
                42,
                60
            })) {
                if(rl.IsMouseButtonPressed(.LEFT)) {
                    if(len(AppState.gameState.handCards) == 0) {
                        append(&AppState.gameState.handCards, cardStack[len(cardStack) - 1])
                        ordered_remove(&cardStack, len(cardStack) - 1)
                        AppState.gameState.handColumnIndex = -3 - idx
                    } else { 
                        if(canStackTableu(AppState.gameState.handCards[:], cardStack[:])) {
                            append(&cardStack, AppState.gameState.handCards[0])
                            clear_dynamic_array(&AppState.gameState.handCards)
                            AppState.gameState.handColumnIndex = -1
                        }
                    }
                }
            }
    }

    if(len(AppState.gameState.handCards) > 0) {
        #reverse for handCard, idx in AppState.gameState.handCards {
            rl.DrawTexture(CardTextures[getCardDataTexture(handCard)], rl.GetMouseX(), rl.GetMouseY() + cast(i32)(8 * idx), rl.WHITE)
        }
    }

    canStartAutoClear := true
    for column in AppState.gameState.columns {
        if(len(column) != 0 && !isStackValid(column[:])) {
            canStartAutoClear = false
        }
    }

    if(len(AppState.gameState.playDeck) != 0 || len(AppState.gameState.handCards) != 0) {
        canStartAutoClear = false
    }

    if(canStartAutoClear && AppState.gameState.clearDelay <= 0.0) {
        columnClear: for &column in AppState.gameState.columns {
            for &tableau in AppState.gameState.tableu {
                if(len(column) > 0) {
                    if(canStackTableu(column[len(column)-1:len(column)], tableau[:])) {
                        append(&tableau, column[len(column)-1])
                        ordered_remove(&column, len(column)-1)
                        AppState.gameState.clearDelay = 0.25
                        break columnClear
                    }
                }
            }
        }
    }

    if(AppState.gameState.clearDelay > 0) {
        AppState.gameState.clearDelay -= rl.GetFrameTime()
    }

    if(isGameWon(AppState.gameState)) {
        AppState.currentInterface = .END_SCREEN
    }

    if(len(AppState.gameState.handCards) > 0) {
        for &card in AppState.gameState.handCards {
            card.hidden = false
        }
    }
}

canStackTableu :: proc(handCards: []CardData, tableuData: []CardData) -> bool {
    if(len(handCards) != 1) {
        return false
    }
    
    if(len(tableuData) == 0) {
        return handCards[0].cardValue == .ACE
    }
    else {
        return handCards[0].suite == tableuData[0].suite && cast(int)handCards[0].cardValue == cast(int)tableuData[len(tableuData) - 1].cardValue + 1
    }
}

canStackColumn :: proc(handCards: []CardData, columnData: []CardData) -> bool {
    if(cast(int)handCards[len(handCards)-1].cardValue != (cast(int)columnData[len(columnData)-1].cardValue - 1)) {
        fmt.printf("HAND: %v COLUMN: %v", handCards[len(handCards)-1], columnData[len(columnData)-1])
        return false
    }

    switch(columnData[len(columnData) - 1].suite) {
        case .CLUBS:
            fallthrough
        case .SPADES:
            return handCards[len(handCards) - 1].suite == .DIAMONDS || handCards[len(handCards) - 1].suite == .HEARTS
        case .DIAMONDS:
            fallthrough
        case .HEARTS:
            return handCards[len(handCards) - 1].suite == .CLUBS || handCards[len(handCards) - 1].suite == .SPADES
    }

    return false
}

isStackValid :: proc(stackCards: []CardData) -> bool {
    for card, idx in stackCards {
        if(idx == 0) { continue }

        if(cast(int)stackCards[idx-1].cardValue != cast(int)card.cardValue + 1) {
            return false
        }

        if((stackCards[idx-1].suite == .CLUBS || stackCards[idx-1].suite == .SPADES) && (card.suite == .CLUBS || card.suite == .SPADES)) {
            return false
        }

        if((stackCards[idx-1].suite == .HEARTS || stackCards[idx-1].suite == .DIAMONDS) && (card.suite == .HEARTS || card.suite == .DIAMONDS)) {
            return false
        }
    }

    return true
}

isGameWon :: proc(gameState: GameState) -> bool {
    return len(gameState.tableu[0]) == 13 &&
        len(gameState.tableu[1]) == 13 &&
        len(gameState.tableu[2]) == 13 &&
        len(gameState.tableu[3]) == 13
}

getCardDataTexture :: proc(card: CardData) -> Cards {
    switch(card.suite) {
        case .HEARTS:
            switch(card.cardValue) {
                case .ACE:
                    return Cards.HEART_A
                case .TWO:
                    return Cards.HEART_2
                case .THREE:
                    return Cards.HEART_3
                case .FOUR:
                    return Cards.HEART_4
                case .FIVE:
                    return Cards.HEART_5
                case.SIX:
                    return Cards.HEART_6
                case .SEVEN:
                    return Cards.HEART_7
                case .EIGHT:
                    return Cards.HEART_8
                case .NINE:
                    return Cards.HEART_9
                case .TEN:
                    return Cards.HEART_10
                case .JACK:
                    return Cards.HEART_J
                case .QUEEN:
                    return Cards.HEART_Q
                case .KING:
                    return Cards.HEART_K
            }
        case .CLUBS:
            switch(card.cardValue) {
                case .ACE:
                    return Cards.CLUB_A
                case .TWO:
                    return Cards.CLUB_2
                case .THREE:
                    return Cards.CLUB_3
                case .FOUR:
                    return Cards.CLUB_4
                case .FIVE:
                    return Cards.CLUB_5
                case.SIX:
                    return Cards.CLUB_6
                case .SEVEN:
                    return Cards.CLUB_7
                case .EIGHT:
                    return Cards.CLUB_8
                case .NINE:
                    return Cards.CLUB_9
                case .TEN:
                    return Cards.CLUB_10
                case .JACK:
                    return Cards.CLUB_J
                case .QUEEN:
                    return Cards.CLUB_Q
                case .KING:
                    return Cards.CLUB_K
            }
        case .DIAMONDS:
            switch(card.cardValue) {
                case .ACE:
                    return Cards.DIAMOND_A
                case .TWO:
                    return Cards.DIAMOND_2
                case .THREE:
                    return Cards.DIAMOND_3
                case .FOUR:
                    return Cards.DIAMOND_4
                case .FIVE:
                    return Cards.DIAMOND_5
                case.SIX:
                    return Cards.DIAMOND_6
                case .SEVEN:
                    return Cards.DIAMOND_7
                case .EIGHT:
                    return Cards.DIAMOND_8
                case .NINE:
                    return Cards.DIAMOND_9
                case .TEN:
                    return Cards.DIAMOND_10
                case .JACK:
                    return Cards.DIAMOND_J
                case .QUEEN:
                    return Cards.DIAMOND_Q
                case .KING:
                    return Cards.DIAMOND_K
            }
        case .SPADES:
            switch(card.cardValue) {
                case .ACE:
                    return Cards.SPADE_A
                case .TWO:
                    return Cards.SPADE_2
                case .THREE:
                    return Cards.SPADE_3
                case .FOUR:
                    return Cards.SPADE_4
                case .FIVE:
                    return Cards.SPADE_5
                case.SIX:
                    return Cards.SPADE_6
                case .SEVEN:
                    return Cards.SPADE_7
                case .EIGHT:
                    return Cards.SPADE_8
                case .NINE:
                    return Cards.SPADE_9
                case .TEN:
                    return Cards.SPADE_10
                case .JACK:
                    return Cards.SPADE_J
                case .QUEEN:
                    return Cards.SPADE_Q
                case .KING:
                    return Cards.SPADE_K
            }
    }

    return .SPADE_A
}

pauseProcess :: proc() {
    if(rl.IsKeyPressed(.ESCAPE)) {
        AppState.currentInterface = .GAME
    }

    menuRect := slice.Rect{
        0,
        0,
        cast(f32)rl.GetRenderWidth(),
        cast(f32)rl.GetRenderHeight(),
    }

    menuRect = slice.decorate_pad(menuRect, cast(f32)rl.GetRenderHeight() * 0.1)
    menuRect = slice.decorate_pad_width(menuRect, cast(f32)rl.GetRenderWidth() * 0.4)

    menuOptionQuit := slice.slice_bottom(&menuRect, 32)
    pauseQuitColor := rl.WHITE
    if(rl.CheckCollisionPointRec(rl.GetMousePosition(), transmute(rl.Rectangle)menuOptionQuit)) {
        if(!rl.CheckCollisionPointRec(rl.GetMousePosition() - rl.GetMouseDelta(), transmute(rl.Rectangle)menuOptionQuit)) {
            play_menu_sound()
        }
        pauseQuitColor = rl.YELLOW
        if(rl.IsMouseButtonDown(.LEFT)) {
            pauseQuitColor = rl.BLUE
        }
        if(rl.IsMouseButtonReleased(.LEFT)) {
            AppState.currentInterface = .MAIN_MENU
        }
    }
    slice.render_rectangle(menuOptionQuit, pauseQuitColor)
    slice.render_center_text("Quit", 24, menuOptionQuit)

    pauseResume := slice.slice_top(&menuRect, 32)
    menuResumeColor := rl.WHITE
    if(rl.CheckCollisionPointRec(rl.GetMousePosition(), transmute(rl.Rectangle)pauseResume)) {
        if(!rl.CheckCollisionPointRec(rl.GetMousePosition() - rl.GetMouseDelta(), transmute(rl.Rectangle)pauseResume)) {
            play_menu_sound()
        }
        menuResumeColor = rl.YELLOW
        if(rl.IsMouseButtonDown(.LEFT)) {
            menuResumeColor = rl.BLUE
        }
        if(rl.IsMouseButtonReleased(.LEFT)) {
            AppState.currentInterface = .GAME
        }
    }
    slice.render_rectangle(pauseResume, menuResumeColor)
    slice.render_center_text("Resume", 24, pauseResume)
}

endProcess :: proc() {
    if(rl.IsKeyPressed(.ESCAPE)) {
        AppState.currentInterface = .GAME
    }

    menuRect := slice.Rect{
        0,
        0,
        cast(f32)rl.GetRenderWidth(),
        cast(f32)rl.GetRenderHeight(),
    }

    menuRect = slice.decorate_pad(menuRect, cast(f32)rl.GetRenderHeight() * 0.1)
    menuRect = slice.decorate_pad_width(menuRect, cast(f32)rl.GetRenderWidth() * 0.2)

    menuEndReturn := slice.slice_bottom(&menuRect, 32)
    menuEndNewgame := slice.slice_bottom(&menuRect, 32)

    menuNewgameColor := rl.WHITE
    if(rl.CheckCollisionPointRec(rl.GetMousePosition(), transmute(rl.Rectangle)menuEndNewgame)) {
        if(!rl.CheckCollisionPointRec(rl.GetMousePosition() - rl.GetMouseDelta(), transmute(rl.Rectangle)menuEndNewgame)) {
            play_menu_sound()
        }

        menuNewgameColor = rl.YELLOW

        if(rl.IsMouseButtonDown(.LEFT)) {
            menuNewgameColor = rl.BLUE
        }
        if(rl.IsMouseButtonReleased(.LEFT)) {
            AppState.gameState = GameState{}
            initializeGame(&AppState.gameState)
            AppState.currentInterface = .GAME
        }
    }
    slice.render_rectangle(menuEndNewgame, menuNewgameColor)
    slice.render_center_text("New Game", 24, menuEndNewgame)

    endReturnColor := rl.WHITE
    if(rl.CheckCollisionPointRec(rl.GetMousePosition(), transmute(rl.Rectangle)menuEndReturn)) {
        if(!rl.CheckCollisionPointRec(rl.GetMousePosition() - rl.GetMouseDelta(), transmute(rl.Rectangle)menuEndReturn)) {
            play_menu_sound()
        }

        endReturnColor = rl.YELLOW
        if(rl.IsMouseButtonDown(.LEFT)) {
            endReturnColor = rl.BLUE
        }
        if(rl.IsMouseButtonReleased(.LEFT)) {
            AppState.currentInterface = .MAIN_MENU
        }
    }
    slice.render_rectangle(menuEndReturn, endReturnColor)
    slice.render_center_text("Return to Menu", 24, menuEndReturn)

    menuEndGameOver := slice.slice_top(&menuRect, 128)

    slice.render_center_text("Victory!", 48, menuEndGameOver, rl.WHITE)
}