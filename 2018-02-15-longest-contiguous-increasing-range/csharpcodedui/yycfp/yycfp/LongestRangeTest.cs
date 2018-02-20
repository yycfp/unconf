using System;
using Microsoft.VisualStudio.TestTools.UITesting;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace yycfp
{

    [CodedUITest]
    public class LongestRangeTest
    {
        private int firstIdxNewRange = 0, secondIdxNewRange = 0;

        [TestMethod]
        public void GetLongestRange()
        {
            int[] givenData = { 1, 3, 5, -9, 11, 12, 13, 15, 78484348, 11, 12, 13, 0, -1, 343, 1222, 0 };

            for (int arrayIndex = 0; arrayIndex < givenData.Length - 1; arrayIndex++)
            {
                #region variables 

                int firstNum = givenData[arrayIndex];

                int secondNum = givenData[arrayIndex + 1];

                int secondNumIndex = arrayIndex + 1;

                #endregion

                if (HasIncrease(firstNum, secondNum)) { 
                    SetRange(firstIdxNewRange, secondNumIndex);
                }
                else { 
                    ResetRange(secondNumIndex);

                    if (HasLongerRange())
                    {
                        SetOutput(StartIndex, EndIndex);
                        SetRange(firstIdxNewRange, secondNumIndex);
                    }
                }
            }
            Console.WriteLine(FirstOutput.ToString() + "," + SecondOuput.ToString());
        }

        public bool HasIncrease(int firstNumber, int secondNumber)
        {
            return firstNumber < secondNumber ? true : false;
        }

        public bool HasLongerRange()
        {
            int currentRange = EndIndex - StartIndex;

            if (currentRange > LongestRange)
            {
                LongestRange = currentRange;
                return true;
            }
            return false;
        }

        public void ResetRange(int reset)
        {
            firstIdxNewRange = secondIdxNewRange = reset;
        }

        public void SetRange(int firstIdx, int secondIdx)
        {
            StartIndex = firstIdx;
            EndIndex = secondIdx;
        }

        public void SetOutput(int firstIdx, int secondIdx)
        {
            FirstOutput = firstIdx;
            SecondOuput = secondIdx;
        }

        private int _startIndex = 0;
        private int _endIndex = 0;
        private int _longestRange = 0;
        private int _firstOutput = 0;
        private int _secondOutput = 0;

        public int StartIndex
        {
            get { return _startIndex; }

            set { _startIndex = value; }
        }

        public int EndIndex
        {
            get { return _endIndex; }
            set { _endIndex = value; }
        }

        public int LongestRange
        {
            get { return _longestRange; }
            set { _longestRange = value; }
        }

        public int FirstOutput
        {
            get { return _firstOutput; }
            set { _firstOutput = value; }
        }

        public int SecondOuput
        {
            get { return _secondOutput; }
            set { _secondOutput = value; }
        }

    }
}
