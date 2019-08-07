library(ggplot2)

e4 = read.csv("e4.csv")

normalized = e4
normalized$Newton = normalized$Newton / max(normalized$Newton) 
normalized$X10k = normalized$X10k / max(normalized$X10k) 
p = ggplot(normalized) + geom_point(aes(x=Time, y=Newton), colour="red") + geom_point(aes(x=Time, y=X10k), colour="blue")
p



data = read.csv("008_015_030.csv")
summary(data)
data$Newton = data$Newton*50
data$seq = 1:length(data[,1])

p = ggplot(data) + geom_line(aes(x=seq, y=R10), colour="blue") + geom_line(aes(x=seq, y=Newton), colour="red")
p



# get resistance from voltage
resistors = data.frame(name=paste("R", 1:13, sep=""), resistance=c(10000000, 1000000, 330000, 100000, 47000, 10000, 4700, 1000, 470, 220, 47, 10, 4.7))

# res = data.frame()
# for(r in paste("R", 1:13, sep="")) {
#   res = rbind(res, data.frame(resistance=r, dist=min(abs(data[,r] - 2048))))
# }

best_res = data.frame()
for(l in 1:length(data[,1])) {
  res = data.frame()
  for(r in paste("R", 1:13, sep="")) {
    res = rbind(res, data.frame(resistance=r, dist=min(abs(data[l,r] - 2048))))
  }
  best_res = rbind(best_res, data.frame(resistance=res[res$dist == min(res$dist), "resistance"][1]))
}
data$BestRes = best_res$resistance

cr = c()
Vi = 3.3
for(l in 1:length(data[,1])) {
  R2 = resistors[resistors$name==best_res[l,"resistance"],"resistance"]
  Vo = (data[l,best_res[l,"resistance"]]/4096)*3.3
  R1 = ((Vi*R2)-(Vo*R2))/Vo
  cr = c(cr, R1)
}
data$ComputedRes = cr

p = ggplot(data) + geom_line(aes(x=seq, y=ComputedRes), colour="blue")
p
