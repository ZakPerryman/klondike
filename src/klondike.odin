package main

import "core:math"
import "core:math/rand"

import rl "vendor:raylib"

initializeKlondike :: proc(gameState: ^KlondikeState) {
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

    play_shuffle_sound()
}

klondikeProcess :: proc() {
    if(rl.IsKeyPressed(.ESCAPE)) {
        AppState.previousInterface = AppState.currentInterface
        AppState.currentInterface = .PAUSE
        return
    }

    if(len(AppState.klondikeState.playDeck) > 0) {
        rl.DrawTexture(CardTextures[getCardType(AppState.klondikeState.playDeck[0])], 0, 16, rl.WHITE)
    } else {
        rl.DrawTexture(CardBack, 0, 16, rl.WHITE)
    }

    // Return logic
    if(rl.IsMouseButtonPressed(.RIGHT) && AppState.klondikeState.handColumnIndex != -1) {
        if(AppState.klondikeState.handColumnIndex <= -3) {
            tableuIndex := math.abs(AppState.klondikeState.handColumnIndex) - 3
            append(&AppState.klondikeState.tableu[tableuIndex], AppState.klondikeState.handCards[0])
            clear_dynamic_array(&AppState.klondikeState.handCards)
            AppState.klondikeState.handColumnIndex = -1
            play_card_sound()
        }
        if(AppState.klondikeState.handColumnIndex == -2) {
            inject_at(&AppState.klondikeState.playDeck, 0, AppState.klondikeState.handCards[0])
            clear_dynamic_array(&AppState.klondikeState.handCards)
            AppState.klondikeState.handColumnIndex = -1
            play_card_sound()
        }
        else
        {
            #reverse for card, cIdx in AppState.klondikeState.handCards {
                append(&AppState.klondikeState.columns[AppState.klondikeState.handColumnIndex], card)
            }
            clear_dynamic_array(&AppState.klondikeState.handCards)
            AppState.klondikeState.handColumnIndex = -1
            play_card_sound()
        }

    }

    // Deck handling logic
    if(len(AppState.klondikeState.playDeck) > 0 && len(AppState.klondikeState.handCards) == 0) {
        if(rl.CheckCollisionPointRec(rl.GetMousePosition(), rl.Rectangle{
            cast(f32)(0 + 11),
            cast(f32)(32 + 2),
            42,
            60
        })) {
            if(rl.IsMouseButtonPressed(.LEFT)){
                append(&AppState.klondikeState.handCards, AppState.klondikeState.playDeck[0])
                ordered_remove(&AppState.klondikeState.playDeck, 0)
                AppState.klondikeState.handColumnIndex = -2
                play_card_sound()
            }
            if(rl.IsMouseButtonPressed(.RIGHT)){
                card := AppState.klondikeState.playDeck[0]
                append(&AppState.klondikeState.playDeck, card)
                ordered_remove(&AppState.klondikeState.playDeck, 0)
                play_card_sound()
            }
        }
    }

    // Column Draw Processing Block
    for &cardStack, idx in AppState.klondikeState.columns {
        stackX : i32 = 48 * cast(i32)idx + 48
        
        if(len(cardStack) == 0) {
            rl.DrawTexture(CardBack, stackX, 32, rl.WHITE)
        }

        for card, cIdx in cardStack {
            if(card.hidden) {
                rl.DrawTexture(CardBack, stackX, cast(i32)cIdx * 16 + 32, rl.WHITE)
            } else {
                rl.DrawTexture(CardTextures[getCardType(card)], stackX, cast(i32)cIdx * 16 + 32, rl.WHITE)
            }
        }
    }

    // Column Logic Processing Block
    for &cardStack, idx in AppState.klondikeState.columns {
        stackX : i32 = 48 * cast(i32)idx + 48

        if(len(cardStack) == 0) {
            if(rl.CheckCollisionPointRec(rl.GetMousePosition(), rl.Rectangle{
                cast(f32)(stackX + 11),
                cast(f32)(32 + 2),
                42,
                60
            })) {
                if(rl.IsMouseButtonPressed(.LEFT)) {
                    if(len(AppState.klondikeState.handCards) > 0) {
                        #reverse for handCard, handIdx in AppState.klondikeState.handCards {
                            append(&cardStack, handCard)
                        }
                        clear_dynamic_array(&AppState.klondikeState.handCards)
                        AppState.klondikeState.handColumnIndex = -1
                        play_card_sound()
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
                    if(len(AppState.klondikeState.handCards) > 0) {
                        if(canStackColumn(AppState.klondikeState.handCards[:], cardStack[:])) {
                            #reverse for handCard, handIdx in AppState.klondikeState.handCards {
                                append(&cardStack, handCard)
                            }
                            clear_dynamic_array(&AppState.klondikeState.handCards)
                            AppState.klondikeState.handColumnIndex = -1
                            play_card_sound()
                        }
                    } else {
                        if(cIdx != len(cardStack) - 1) {
                            if(isStackValid(cardStack[cIdx:len(cardStack)])) {
                                AppState.klondikeState.handColumnIndex = idx
                                if(cIdx > 0) {
                                    cardStack[cIdx - 1].hidden = false
                                }
                                for newHandCardIdx := len(cardStack) - 1; newHandCardIdx >= cIdx; newHandCardIdx -= 1 {
                                    append(&AppState.klondikeState.handCards, cardStack[newHandCardIdx])
                                    ordered_remove(&cardStack, newHandCardIdx)
                                }
                                play_card_sound()
                            }
                        } else {
                            if(cIdx > 0) {
                                cardStack[cIdx - 1].hidden = false
                            }
                            AppState.klondikeState.handColumnIndex = idx
                            append(&AppState.klondikeState.handCards, card)
                            ordered_remove(&cardStack, cIdx)
                            play_card_sound()
                        }
                    }
                    break
                }
            }
        }
    }

    // Tableu Draw Processing Block
    for cardStack, idx in AppState.klondikeState.tableu {
        stackX : i32 = 48 * cast(i32)idx + 48 * 8
        if(len(cardStack) == 0) {
            rl.DrawTexture(CardBack, stackX, 16, rl.WHITE)
        } else {
            card := cardStack[len(cardStack) - 1]
            rl.DrawTexture(CardTextures[getCardType(card)], stackX, 16, rl.WHITE)
        }
    }

    // Tableu Logic Processing Block
    for &cardStack, idx in AppState.klondikeState.tableu {
        stackX : i32 = 48 * cast(i32)idx + 48 * 8

        if(rl.CheckCollisionPointRec(rl.GetMousePosition(), rl.Rectangle{
                cast(f32)(stackX + 11),
                cast(f32)(32 + 2),
                42,
                60
            })) {
                if(rl.IsMouseButtonPressed(.LEFT)) {
                    if(len(AppState.klondikeState.handCards) == 0) {
                        append(&AppState.klondikeState.handCards, cardStack[len(cardStack) - 1])
                        ordered_remove(&cardStack, len(cardStack) - 1)
                        AppState.klondikeState.handColumnIndex = -3 - idx
                        play_card_sound()
                    } else { 
                        if(canStackTableu(AppState.klondikeState.handCards[:], cardStack[:])) {
                            append(&cardStack, AppState.klondikeState.handCards[0])
                            clear_dynamic_array(&AppState.klondikeState.handCards)
                            AppState.klondikeState.handColumnIndex = -1
                            play_card_sound()
                        }
                    }
                }
            }
    }

    if(len(AppState.klondikeState.handCards) > 0) {
        #reverse for handCard, idx in AppState.klondikeState.handCards {
            rl.DrawTexture(CardTextures[getCardType(handCard)], rl.GetMouseX(), rl.GetMouseY() + cast(i32)(8 * idx), rl.WHITE)
        }
    }

    canStartAutoClear := true
    for column in AppState.klondikeState.columns {
        if(len(column) != 0 && !isStackValid(column[:])) {
            canStartAutoClear = false
        }
    }

    if(len(AppState.klondikeState.playDeck) != 0 || len(AppState.klondikeState.handCards) != 0) {
        canStartAutoClear = false
    }

    if(canStartAutoClear && AppState.klondikeState.clearDelay <= 0.0) {
        columnClear: for &column in AppState.klondikeState.columns {
            for &tableau in AppState.klondikeState.tableu {
                if(len(column) > 0) {
                    if(canStackTableu(column[len(column)-1:len(column)], tableau[:])) {
                        append(&tableau, column[len(column)-1])
                        ordered_remove(&column, len(column)-1)
                        AppState.klondikeState.clearDelay = 0.25
                        play_card_sound()
                        break columnClear
                    }
                }
            }
        }
    }

    if(AppState.klondikeState.clearDelay > 0) {
        AppState.klondikeState.clearDelay -= rl.GetFrameTime()
    }

    if(isKlondikeWon(AppState.klondikeState)) {
        AppState.previousInterface = AppState.currentInterface
        AppState.currentInterface = .END_SCREEN
    }

    if(len(AppState.klondikeState.handCards) > 0) {
        for &card in AppState.klondikeState.handCards {
            card.hidden = false
        }
    }
}