package object yycfp {

  def longestContiguousIncreasingRange[T: Ordering](xs: Seq[T]): Option[(Int, Int)] = {
    if (xs.nonEmpty) {
      val indices = for {
        i <- xs.indices
        if i > 0 && implicitly[Ordering[T]].lteq(xs(i), xs(i-1))
      } yield i

      val (index, length) = (0 +: indices :+ xs.size)
        .sliding(2)
        .map({ case Seq(l, r) => (l, r - l) })
        .maxBy(_._2)
      
      Some(index, index + length - 1)
    } else None
  }

}
