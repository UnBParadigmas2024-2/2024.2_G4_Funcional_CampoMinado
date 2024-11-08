module Game where

import Grid (generateGrid, revealBombs, Grid)
import BFS (bfs)
import Node (Node(..), bomba)

data GameState = GameState {
    state'grid     :: Grid,
    state'size     :: Int,      -- Dimensões da grade
    state'cnt      :: Int,      -- Qtd de células reveladas
    state'win      :: Int,      -- Qtd de células reveladas pra ganhar
    state'remainingBombs :: Int, 
    state'finished :: Bool,
    state'lose     :: Bool
}


-- Função para pedir o nível de dificuldade
askDifficulty :: IO String
askDifficulty = do
    putStrLn "Choose difficulty level (easy, normal, hard):"
    difficulty <- getLine
    return difficulty

-- Função para adaptar a geração de bombas com base na dificuldade
getBombChance :: String -> Int -> Int
getBombChance "easy" size = max 1 (size * size `div` 10)   
getBombChance "normal" size = max 2 (size * size `div` 5)  
getBombChance "hard" size = max 3 (size * size `div` 3)    -- quanto menor o valor, maior a dificuldade
getBombChance _ size = max 2 (size * size `div` 5)         


gameInit :: Int -> String -> IO (GameState)
gameInit size difficulty = do
    let bombChance = getBombChance difficulty size  -- Passa o tamanho do grid
    (grid, cntBombs) <- generateGrid size bombChance  -- Gerar o grid com base no número de bombas
    let win = size * size - cntBombs  -- Condição de vitória

    return (GameState grid size 0 win cntBombs False False)

gameUpdate :: GameState -> Int -> Int -> Bool -> IO (GameState)
gameUpdate state row col isSettingFlag = do
    (res, newCnt, newGrid) <- bfs (state'grid  state) (state'size  state) (row, col) (state'cnt state) (state'win state) isSettingFlag

    let hasWon   = (state'win state) == (state'cnt state)
    let hasLost  = not hasWon && not res
    let finished = hasLost || hasWon 

    return $ GameState
        newGrid
        (state'size state)
        newCnt
        (state'win state)
        (state'remainingBombs state)
        finished
        hasLost


playGame :: Int -> String -> IO ()
playGame size difficulty = do
    let bombChance = getBombChance difficulty size  -- Passa o tamanho do grid
    (grid, cntBombs) <- generateGrid size bombChance  -- Gerar o grid com base no número de bombas
    let win = size * size - cntBombs  -- Condição de vitória

    -- Inicia o loop de jogo, passando o número de bombas
    gameLoop grid size 0 win cntBombs

gameLoop :: Grid -> Int -> Int -> Int -> Int -> IO ()
gameLoop grid size cnt win cntBombs = do
    -- Exibe o número de bombas antes de cada movimento
    putStrLn $ "Number of bombs: " ++ show cntBombs
    printGrid grid
    putStrLn "Enter your move \"row col\" or set a flag \"row col 1\":"
    move <- getLine
    let userInput = words move
    let [row, col] = map (\x -> read x - 1) (take 2 userInput) :: [Int] 
    let initialQueue = [(row, col)]  -- A fila começa com a coordenada inicial
    
    let flag = if length userInput <= 2 then False else True

    (res, newCnt, newGrid) <- bfs grid size (row, col) cnt win flag
    gameLoop' newCnt newGrid res cntBombs

  where
    gameLoop' newCnt newGrid res cntBombs
      | newCnt == win = do
          printGrid newGrid
          putStrLn "You win!"
      | not res = do
          let finalGrid = revealBombs newGrid  -- Revela as bombas no grid final
          printGrid finalGrid
          putStrLn "You lose!"
      | otherwise = gameLoop newGrid size newCnt win cntBombs  -- Continua o jogo com o novo grid e contador

-- Imprime o grid
printGrid :: Grid -> IO ()
printGrid = mapM_ (putStrLn . unwords . map showNode)
  where
    showNode (Node d v f)
        | not v && f == False = "_"
        | not v && f == True = "!" -- Sinalização de possível bomba
        | d == bomba = "*"  -- Mostrar a bomba
        | otherwise = show d

-- Função main
main :: IO ()
main = do
    putStrLn "Enter the grid size:"
    size <- readLn :: IO Int
    difficulty <- askDifficulty
    playGame size difficulty
