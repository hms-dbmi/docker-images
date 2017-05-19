# list available packages
library()

# run Cair test
library(ggplot2)
library(Cairo)
qplot(wt, mpg, data=mtcars)+geom_abline(intercept=20)
ggsave("TEST.png")
CairoPNG("TEST.png", width=4, height=4)

if(!file.exists("TEST.png")) {
    print("ERROR: File does not exists")
    stop()
}

file.remove("TEST.png")
