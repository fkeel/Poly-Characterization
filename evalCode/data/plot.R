library(ggplot2)

e4 = read.csv("e4.csv")

normalized = e4
normalized$Newton = normalized$Newton / max(normalized$Newton) 
normalized$X10k = normalized$X10k / max(normalized$X10k) 
p = ggplot(normalized) + geom_point(aes(x=Time, y=Newton), colour="red") + geom_point(aes(x=Time, y=X10k), colour="blue")
p
