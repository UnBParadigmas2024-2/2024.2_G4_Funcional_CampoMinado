module BFS where

import Node (Node(..), bomba)
import Node (Coord)
import Grid (Grid, check, updateGrid, showFlag)

bfs :: Grid -> Int -> Coord -> Int -> Int -> Bool -> IO (Bool, Int, Grid)
bfs grid size (i, j) cnt win flag = bfsRec grid [(i, j)] size cnt win flag

bfsRec :: Grid -> [Coord] -> Int -> Int -> Int -> Bool -> IO (Bool, Int, Grid)
bfsRec grid [] _ cnt _ _ = return (True, cnt, grid)  -- Se a fila está vazia, acabou
bfsRec grid ((i, j):queue) size cnt win flag
    | flag == True && not (visited node) = do
        let gridWithFlag = showFlag grid i j
        bfsRec gridWithFlag queue size cnt win True
    | dataNode node == bomba = return (False, cnt, grid)  -- Bomba, perdeu
    | cnt == win = return (True, cnt, grid)  -- Se o contador atingir a quantidade total de células visitáveis, ganhou
    | visited node = bfsRec grid queue size cnt win False  -- Se o nó já foi visitado, segue pro prox
    | dataNode node /= 0 = do  -- Se for número, não visita mais nada
        let newGrid = updateGrid grid i j
            newCnt
                | not (visited node) = cnt + 1
                | otherwise = cnt
        bfsRec newGrid queue size newCnt win False
    | otherwise = do
        let newGrid = updateGrid grid i j
            newCnt
                | not (visited node) = cnt + 1
                | otherwise = cnt
        let expandedQueue = expandQueue newGrid size (i, j) queue
        bfsRec newGrid expandedQueue size newCnt win False
  where
    node = grid !! i !! j  -- Obtém o nó correspondente à coordenada (i, j)

expandQueue :: Grid -> Int -> Coord -> [Coord] -> [Coord]
expandQueue grid size (x, y) queue = foldl (\q (dx, dy) -> if check grid size (x + dx, y + dy) && not (visited (grid !! (x + dx) !! (y + dy))) then q ++ [(x + dx, y + dy)] else q) queue dxy
  where dxy = [(-1, 0), (0, 1), (1, 0), (0, -1)]
