library(ggplot2)
library(zoo)
library(reshape2)
df<-read.csv("rosegraph.csv",stringsAsFactors = FALSE)
df$date <-as.Date(paste(df$date,1,sep="-"),"%Y-%m-%d")

df_melt<-melt(df,id.vars=c("date","total"))

myAngle <-seq(-20,-340,length.out = 12)


ggplot(df_melt, aes(x =factor(date), y=value, fill = variable)) +
  geom_bar(width = 0.8, size=0.1,stat="identity",
           position="identity", color="black",alpha=1)+ 
  scale_y_sqrt()+
  scale_x_discrete(labels=format(df$date,"%y-%m"))+
  #coord_polar(start=3*pi/2)+ #极坐标变换
  #ggtitle("Causes of Mortality in the Crimean War:1854.4~1855.3") +
  xlab("")+
  theme_light()+
  theme(#axis.text.x=element_text(size = 13,colour="black",angle =90+ myAngle),
      panel.border = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line.y =element_blank(),
      axis.text = element_text(color='black'))

ggplot(df_melt, aes(x =factor(date), y=value, fill = variable)) +
  geom_bar(width = 1, size=0.1,stat="identity",
           position="identity", color="black",alpha=1)+ 
  scale_y_sqrt()+
  scale_x_discrete(labels=format(df$date,"%y-%m"))+
  coord_polar(start=3*pi/2)+ #极坐标变换
  ggtitle("Causes of Mortality in the Crimean War:1854.4~1855.3") +
  xlab("")+
  theme_light()+
  theme(axis.text.x=element_text(size = 13,colour="black",angle =90+ myAngle),
        panel.grid.major.x = element_line(color='gray70'),
        panel.grid.major.y = element_line(color='gray70'))