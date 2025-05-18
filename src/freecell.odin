package main

import "core:math/rand"

import rl "vendor:raylib"

initializeFreecell :: proc(gameState: ^FreecellState) {
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

    for &card in gameState.deck {
        card.hidden = false
        append(&gameState.playDeck, card)
    }

    column := 0
    for card, idx in gameState.playDeck {
        append(&gameState.columns[column], card)
        column += 1
        if(column >= len(gameState.columns)) {
            column = 0
        }
    }
    clear_dynamic_array(&gameState.playDeck)
}

freecellProcess :: proc() {
    if(rl.IsKeyPressed(.ESCAPE)) {
        AppState.previousInterface = AppState.currentInterface
        AppState.currentInterface = .PAUSE
        return
    }

    // Hand return logic
    if(rl.IsMouseButtonPressed(.RIGHT)) {
        if(AppState.freecellState.handColumnIndex != -1) {
           if(AppState.freecellState.handColumnIndex >= 0) {
                #reverse for card in AppState.freecellState.handCards {
                    append(&AppState.freecellState.columns[AppState.freecellState.handColumnIndex], card)
                }
                clear_dynamic_array(&AppState.freecellState.handCards)
                AppState.freecellState.handColumnIndex = -1
           } 
        }
    }

    // Column Drawing
    columnYOffset := 128
    for column, columnIndex in AppState.freecellState.columns {
        columnXOffset := 32 + columnIndex * 64
        if(len(column) == 0) {
            rl.DrawTexture(CardBack, cast(i32)columnXOffset, cast(i32)(columnYOffset), rl.WHITE)
        } else {
            for card, cardIndex in column {
                cardYOffset := 0 + cardIndex * 24
    
                drawTexture : rl.Texture2D = card.hidden ? CardBack : CardTextures[getCardType(card)]
    
                rl.DrawTexture(drawTexture, cast(i32)columnXOffset, cast(i32)(columnYOffset + cardYOffset), rl.WHITE)
            }
        }
    }

    // Column Logic
    for &column, columnIndex in AppState.freecellState.columns {
        columnXOffset := 32 + columnIndex * 64

        if(len(column) == 0) {
            if(rl.CheckCollisionPointRec(rl.GetMousePosition(), {
                    cast(f32)(columnXOffset + 11),
                    cast(f32)(columnYOffset + 2),
                    42,
                    60
                })) {
                    if(rl.IsMouseButtonPressed(.LEFT)) {
                        if(len(AppState.freecellState.handCards) > 0) {
                            #reverse for handCard in AppState.freecellState.handCards {
                                append(&column, handCard)
                            }
                            clear_dynamic_array(&AppState.freecellState.handCards)
                        }
                    }
                }
        } else {
            #reverse for card, cardIndex in column {
                cardYOffset := 0 + cardIndex * 24
    
                if(rl.CheckCollisionPointRec(rl.GetMousePosition(), {
                    cast(f32)(columnXOffset + 11),
                    cast(f32)(columnYOffset + cardYOffset + 2),
                    42,
                    60
                })) {
                    if(rl.IsMouseButtonPressed(.LEFT)) {
                        if(len(AppState.freecellState.handCards) == 0) {
                            AppState.freecellState.handColumnIndex = columnIndex
                            if cardIndex == len(column) - 1 {
                                append(&AppState.freecellState.handCards, card)
                                ordered_remove(&column, cardIndex)
                                break
                            } else {
                                if (isStackValid(column[cardIndex:len(column)]) && len(column[cardIndex:len(column)]) <= validStackSize(AppState.freecellState)) {
                                    #reverse for card in column[cardIndex:len(column)] {
                                        append(&AppState.freecellState.handCards, card)
                                    }
                                    for index := cardIndex; index < len(column); {
                                        ordered_remove(&column, index)
                                    }
                                }
                            }
                        } else {
                            if(canStackColumn(AppState.freecellState.handCards[:], column[:])) {
                                #reverse for handCard in AppState.freecellState.handCards {
                                    append(&column, handCard)
                                }
                                clear(&AppState.freecellState.handCards)
                                AppState.freecellState.handColumnIndex = -1
                                break
                            }
                        }
                    }
                }
            }
        }
    }

    // Cell drawing
    for cell, cellIndex in AppState.freecellState.cells {
        cardTexture : rl.Texture2D
        if(cell == CardData{}) {
            cardTexture = CardBack
        } else {
            cardTexture = CardTextures[getCardType(cell)]
        }

        rl.DrawTexture(cardTexture, cast(i32)(0 + cellIndex * 48), 16, rl.WHITE)
    }

    // Cell logic
    for &cell, cellIndex in AppState.freecellState.cells {
        if(rl.CheckCollisionPointRec(rl.GetMousePosition(), {
            cast(f32)(0 + cellIndex * 48) + 11, 16 + 2, 42, 60
        })) {
            if(rl.IsMouseButtonPressed(.LEFT)) {
                if(len(AppState.freecellState.handCards) == 1) {
                    if(cell == CardData{}) {
                        AppState.freecellState.cells[cellIndex] = AppState.freecellState.handCards[0]
                        clear_dynamic_array(&AppState.freecellState.handCards)
                    }
                } else if(len(AppState.freecellState.handCards) == 0) {
                    append(&AppState.freecellState.handCards, cell)
                    AppState.freecellState.cells[cellIndex] = CardData{}
                }
            }
        }
    }

    // Tableu drawing
    for tableu, tableuIndex in AppState.freecellState.tableu {
        cardTexture := CardBack
        if(len(tableu) != 0) {
            card := tableu[len(tableu) - 1]
            cardTexture = CardTextures[getCardType(card)]
        }
        rl.DrawTexture(cardTexture, cast(i32)(256 + tableuIndex * 48), 16, rl.WHITE)
    }

    // Tableu logic
    for &tableu, tableuIndex in AppState.freecellState.tableu {
        if(rl.CheckCollisionPointRec(rl.GetMousePosition(), {
            cast(f32)(256 + tableuIndex * 48) + 11, 16 + 2, 42, 60
        })) {
            if(rl.IsMouseButtonPressed(.LEFT)) {
                if(len(AppState.freecellState.handCards) == 1) {
                    if canStackTableu(AppState.freecellState.handCards[:], tableu[:]) {
                        append(&tableu, AppState.freecellState.handCards[0])
                        clear_dynamic_array(&AppState.freecellState.handCards)
                    }
                } else if(len(AppState.freecellState.handCards) == 0 && len(tableu) > 0) {
                    append(&AppState.freecellState.handCards, tableu[len(tableu) - 1])
                    ordered_remove(&tableu, len(tableu) - 1)
                }
            }
        }
    }

    // Hand drawing
    if(len(AppState.freecellState.handCards) > 0) {
        #reverse for handCard, idx in AppState.freecellState.handCards {
            rl.DrawTexture(CardTextures[getCardType(handCard)], rl.GetMouseX(), rl.GetMouseY() + cast(i32)(8 * idx), rl.WHITE)
        }
    }

    if(isFreecellWon(AppState.freecellState)) {
        AppState.previousInterface = AppState.currentInterface
        AppState.currentInterface = .END_SCREEN
    }
}

validStackSize :: proc(gameState: FreecellState) -> (count:int = 1) {
    for cell in gameState.cells {
        if(cell == CardData{}) {
            count += 1
        }
    }

    freeColumns := 1
    for column in gameState.columns {
        if(len(column) == 0) {
            freeColumns += 1
        }
    }

    count *= freeColumns
    return
}