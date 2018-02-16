import scala.annotation.tailrec

package object yycfp {

  def longestContiguousIncreasingRange[T: Ordering](xs: Seq[T]): Option[(Int, Int)] = {
    if (xs.nonEmpty) {
      // we'll use this locally scoped partial to return the index when the current value is <=previous
      val decreasingChange: PartialFunction[(T, Int), Int] = {
        case (x, i) if i > 0 && implicitly[Ordering[T]].lteq(x, xs(i - 1)) => i
      }

      // detect all the changes based on the decreasingChange function above
      val changes = 0 +: xs.zipWithIndex.collect(decreasingChange) :+ xs.size

      // find the longest chain
      val (index, length) = changes
        .sliding(2)
        .map({ case Seq(l, r) => (l, r - l) })
        .maxBy(_._2)

      // calculate the two indexes
      Some(index, index + length - 1)
    } else None
  }

}
