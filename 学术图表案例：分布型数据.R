
#EasyShu团队出品，
#如需使用与深入学习，请联系微信：EasyCharts
library(ggpubr)
library(ggplot2)
library(RColorBrewer)
library(tidyr)
library(ggalt)
library(dplyr)
set.seed(12345)

df<-read.csv('Example_Distribution_Data.csv',check.names = FALSE)
df_melt<-gather(df,key = "key", value = "value",-group)

df_sim<-data.frame(group = character(),class = character(),value = numeric())
for (i in 1:nrow(df_melt)){
  value<-rnorm(100, mean = df_melt$value[i], sd = runif(1,min=0.5,max=0.8))
  df_sim<-rbind(df_sim,data.frame(group = df_melt$group[i],
                                  class = df_melt$key[i],
                                 value = value))}
df_sim$class<-factor(df_sim$class,levels=colnames(df)[2:6])
df_sim$group<-factor(df_sim$group,levels=df$group)
df_sim$value[df_sim$value<0]<-0
df_sim$value[df_sim$value>6]<-NaN

ggplot(df_sim, aes(group, value,fill=class))+ 
  stat_summary(fun.y=mean, fun.args = list(mult=1),geom='bar',
               position = position_dodge(0.8),colour="black",width=0.8,size=0.2)+
  stat_summary(fun.data = mean_sdl,fun.args = list(mult=1), geom='errorbar',
               position = position_dodge(0.8),color='black',width=.0,size=0.5)+
  scale_fill_brewer(palette="YlGnBu",direction=-1,name="")+
  scale_y_continuous(limits=c(0,6),expand=c(0,0))+
  xlab("")+
  theme_light()+
  theme(legend.position = 'top',
        panel.border = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        axis.line.y =element_blank(),
        axis.text = element_text(color='black'))

ggplot(df_sim, aes(group, value,fill=class))+ 
  geom_boxplot(outlier.size = 1, aes(fill=factor(class)), 
               position = position_dodge(0.8),size=0.1) +
 # guides(fill=guide_legend(title="class"))+
  scale_fill_brewer(palette="YlGnBu",direction=-1,name="")+
  scale_y_continuous(limits=c(2,6.5),expand=c(0,0))+
  xlab("")+
  theme_light()+
  theme(legend.position = 'top',
        panel.border = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.line.y =element_blank(),
        axis.text = element_text(color='black'))


library(ggpubr)

ggplot(df_sim, aes(x=group,y=value,fill=group))+ 
  geom_boxplot(aes(fill=factor(group)), #outlier.size = 1, 
               width=0.8,
               position = position_dodge(0.1),size=0.25) +
  guides(fill=guide_legend(title="group"),show=FALSE)+
  scale_fill_brewer(palette="YlGnBu",direction=-1)+
  facet_grid(.~class)+
  #geom_hline(aes(yintercept = mean(value)), linetype = 2)+
  stat_compare_means(aes(label =..p.format..),
                     #map_signif_level = c("***"=0.001, "**"=0.01, "*"=0.05," "=2),
                     method = "anova", 
                     label.x=0.8,label.y =2.)+
  #stat_compare_means(label = "p.signif", 
  #                   method = "t.test",ref.group = ".all.", 
  #                   hide.ns = TRUE,label.y = 9) +
  #添加每组变量与全部数据的显著性
  #scale_x_discrete(labels=c("HK","China","Foreign"))+
  scale_x_discrete(labels=c("H","C","F"))+
  #theme_light()+
  theme(legend.position = "none")#,
        #panel.border = element_blank(),
        #panel.grid.major.x = element_blank(),
        #axis.line.y =element_blank(),
        #axis.text = element_text(color='black'))
 

ggplot(df_sim, aes(x=group,y=value,fill=group))+ 
  geom_violin(outlier.size = 1, aes(fill=factor(group)), 
               width=0.8,
               position = position_dodge(0.1),size=0.25) +
  guides(fill=guide_legend(title="group"),show=FALSE)+
  scale_fill_brewer(palette="YlGnBu",direction=-1)+
  facet_grid(.~class)+
  #geom_hline(aes(yintercept = mean(value)), linetype = 2)+
  stat_compare_means(aes(label =..p.format..),
                     #map_signif_level = c("***"=0.001, "**"=0.01, "*"=0.05," "=2),
                     method = "anova", 
                     label.x=0.8,label.y =2.)+
  #stat_compare_means(label = "p.signif", 
  #                   method = "t.test",ref.group = ".all.", 
  #                   hide.ns = TRUE,label.y = 9) +
  #添加每组变量与全部数据的显著性
  #scale_x_discrete(labels=c("HK","China","Foreign"))+
  scale_x_discrete(labels=c("H","C","F"))+
  #theme_light()+
  theme(legend.position = "none")#,
#panel.border = element_blank(),
#panel.grid.major.x = element_blank(),
#axis.line.y =element_blank(),
#axis.text = element_text(color='black'))
