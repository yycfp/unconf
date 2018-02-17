
import Data.Monoid

-- type aliases
type Idx = Int
type Len = Int
type Inc = Bool

-- each index in a list (starting at the second element) is either at
-- the end of an increasing run, or not
data Run = Run Idx Len | NoRun Idx
  deriving (Show, Eq)

-- runs sort longest, then earliest
instance Ord Run where
   compare (NoRun _) (Run _ _)     = LT
   compare (Run _ _) (NoRun _)     = GT
   compare (NoRun i1) (NoRun i2)   = compare i2 i1
   compare (Run i1 l1) (Run i2 l2) = compare l1 l2 <> compare i2 i1

-- find the longest increasing run in a sortable list
find :: Ord a => [a] -> Maybe Run
find [] = Nothing
find list = Just best
  where
    curr = drop 1 list                  -- starting with the second item
    incr = zipWith (<) list curr        -- is it larger than previous item?
    indx = zip [1..] incr               -- label the answer with list index
    runs = scanl run (NoRun 0) indx     -- then detect all runs
      where
        run _ (i, False) = NoRun i         -- not larger -> no run
        run (NoRun i) _  = Run i 1         -- larger and not in a run -> new run
        run (Run i l) _  = Run i (l+1)     -- larger and in a run -> extend run
    best = maximum runs                 -- finally, pick the best one

-- format a run for printing
view :: Maybe Run -> String
view Nothing          = "None"
view (Just (NoRun i)) = "(" ++ show i ++ ",0)"
view (Just (Run i l)) = "(" ++ show i ++ "," ++ show (i + l) ++ ")"

-- given a list, find the longest run, then format and print it
x :: Ord a => [a] -> IO ()
x = putStrLn . view . find

-- do several test cases
main = do
    x [1, 3, 5, -9, 11, 12, 13, 15, 78484348, 11, 12 ,13, 0, -1, 343, 1222, 0]
    x ['a', 'c', 'b', 'd']
    x [5, 4, 3, 2, 1]
    x [1]
    x [1, 2]
    x ([] :: [Int])
    x [2, 1, 2, 3, 2, 1, 2, 3]
