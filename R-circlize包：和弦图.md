---
tiltle: circlize包画和弦图
作者：Li_Yuhui
四川大学在读研究生
---
[参考来源](https://jokergoo.github.io/circlize_book/book/the-chorddiagram-function.html)  
----
@[TOC]
------
# par参数： 
 
* lty: line type. 可以是数字或者字符,   
  (0 = "blank", 1 = "solid" (default), 2 = "dashed", 3 = "dotted", 4 = "dotdash", 5 = "longdash", 6 = "twodash")  
* lwd: line width. 默认是 1, 设置线宽的放大倍数.
* cex: 设置文字和符号相对于默认值的大小, 为一个比例数值. 当使用 mfrow 或 mfcol 也会改变该值.
* mai: 以 inch 为单位的图像边距, c(bottom, left, top, right).
* mar: 以行数来表示图像边距, c(bottom, left, top, right), 默认是 c(5, 4, 4, 2) + 0.1.
* mfcol, mfrow: 调整图形输出设备中子图排列的向量, c(nrow, ncol), 
  mfcol 让子图按照列优先排列, 相应的, mfrow 让子图按照行优先排列.当设置 mfcol mfrow 后, cex 和 mex 的基本单位都相应减小.  
[参考来源及其它参数](https://zhuanlan.zhihu.com/p/21394945)  

# 和弦图

## 和弦图简介
和弦图长什么样子：  
[和弦图在线](http://circos.ca/intro/tabular_visualization/)  
和弦图即可以反映2类变量之间的相互作用关系，也可以反映相互作用强度，这是其它图比不了的  
和弦图的弦link的宽度代表所连接的两个对象的相互作用强弱，link越宽，则相互作用越强  
和弦图常用于绘制国家之间的贸易往来量，城市之间的航班往来量，还有细胞和基因数据可视化(这个领域不了解)  

### 邻接表(和弦图数据源)
邻接表强调2类对象之间的相互作用强弱，分为邻接矩阵(adjacency matrix)和邻接列表(adjacency list)  
* 邻接矩阵为表示矩阵格式，邻接矩阵的元素映射到弦link的宽度，表示所在行名称和列名称的相互作用强弱  
* 邻接列表通常前2列分别为2类对象，第3列映射到弦link的宽度，表示前2列对应行的元素相互作用强弱    
circlize内置的和弦图绘制函数`chordDiagram()`对这2种邻接表都支持，但对于后续参数修改，使用邻接列表更方便  
**邻接表：**  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

# 编一个邻接矩阵
mat <- matrix(1:9, 3) # 第1列不是id列，通过行命名替代
rownames(mat) <-  letters[1:3]
colnames(mat) <-  LETTERS[1:3]
mat

# 编一个邻接列表
df <- data.frame(from = letters[1:3], to = LETTERS[1:3], value = 1:3)
df
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107103424951.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)

**可以使用内置函数`generateRandomBed()`产生随机基因类数据：**    
语法：
`generateRandomBed(nr = 10000, nc = 1, fun = function(k) rnorm(k, 0, 0.5), species = NULL)` 
参数解释：  
* nr 表示指定产生数据行数 
* nc 表示指定产生数据列数, 数据值的列   
* fun 表示指定参数随机数的方法  
* species 表示种类，传递给`read.cytoband`  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

set.seed(999)
bed = generateRandomBed() # 默认参数
head(bed)

bed = generateRandomBed(nr = 200, nc = 4)
nrow(bed)

bed = generateRandomBed(nc = 2, fun = function(k) sample(letters, k, replace = TRUE)) # 默认产生1000行数据
head(bed)

```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107103522595.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)

## 初步绘图  
输入邻接表数据，默认参数，自动绘图，    
**构造数据**  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=TRUE, fig.show='hold'}
library(circlize)

# 构造一个邻接矩阵
set.seed(999)
mat <- matrix(sample(18, 18), 3, 6) # 3行6列的矩阵
rownames(mat) <- paste0("S", 1:3) # 生成行名
colnames(mat) <- paste0("E", 1:6) # 生成列名

# 构造一个邻接列表
df <- data.frame(from = rep(rownames(mat), times = ncol(mat)), # 第1列对象
                 to = rep(colnames(mat), each = nrow(mat)), # 第2列对象
                 value = as.vector(mat),  # 第3列前2列对象相互作用强度
                 stringsAsFactors = FALSE)
df

```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107103620752.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)

**绘图**  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

# 使用邻接矩阵
chordDiagram(mat) 
circos.clear() # 结束绘图，否则会继续叠加图层

# 使用邻接列表
chordDiagram(df)
circos.clear() 
```
![邻接矩阵绘图](https://img-blog.csdnimg.cn/20181107103646743.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![邻接列表绘图](https://img-blog.csdnimg.cn/2018110710371595.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
# 参数调整 
调整了参数，绘图结束后，使用`circos.clear()`重置参数，使返回到默认状态  
参数分为2大类：  
* 第1类为`circos.par()`内置参数   
* 第2类为`chordDiagram()`内置参数  

## `circos.par`内置参数 
| 分类 | 参数 | 描述 |
| ----------------- | --------------------- | -------------------------------------------------------------- |
| sectors间隙       | `gap.after`           | 调整外围sectors之间的间隙，用数字向量进行指定 |
| sectors旋转方向   | `clock.wise`          | 为逻辑值，设置外围sectors的旋转方向  |
| sectors起点位置   | `start.degree`        | 为-360到360的数字，调整第一个sector的位置，与旋转方向有关  |

### gap 间隙调整
sectors之间的间隙可以用`gap.after = `调整  
指定间隙的数字向量长度应该与sectors数量一致  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

# 使用邻接矩阵时
circos.par(gap.after = c(rep(5, nrow(mat)-1),  # 2个5，表示3个行名之间的间隙分别为5个单位
                         15,                   # 表示行名与列名之间的间隙，为15个单位
                         rep(5, ncol(mat)-1),  # 5个5，表示6个列名之间的间隙分别为5个单位
                         15))                  # 表示列名与行名之间的间隙，为15个单位
chordDiagram(mat) 
circos.clear() # 返回默认设置

# 使用邻接列表时
circos.par(gap.after = c(rep(5, length(unique(df[[1]]))-1), # 表示第1列元素之间的间隙为5个单位
                         15,                                # 表示第1列与第2列之间的间隙为15个单位
                         rep(5, length(unique(df[[2]]))-1), # 表示第2列元素之间的间隙为5个单位
                         15))                               # 表示第2列与第1列之间的间隙为15个单位  
chordDiagram(df)
circos.clear()
```
![使用邻接矩阵时](https://img-blog.csdnimg.cn/20181107103846124.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![使用邻接列表时](https://img-blog.csdnimg.cn/201811071039078.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### sector起点位置及旋转方向调整
sector默认为3点钟顺时针方向， 
* `circos.par(start.degree = )`可以调整起点位置，起点位置还与旋转方向有关  
* `circos.par(clock.wise = FALSE/TRUE)` 可以调整旋转方向   
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

circos.par(start.degree = 90, clock.wise = FALSE) # 逆时针旋转，起点位置在逆时针90度方向，即12点针方向  
chordDiagram(mat)
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104027102.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
## `chordDiagram`内置参数

`chordDiagram()`内置参数很多，分类及作用如下：  

| 分类 | 参数 | 描述 |
| --------------- | ------------------ | ------------------------------------------------------------------------------------ |
| sectors顺序     | `order`            | 调整外围sectors排列顺序，用字符串向量指定，其长度与sectors数量一致 |
| sectors颜色     | `grid.col`         | 调整外围sectors颜色，颜色向量指定，通常使用名称属性进行匹配，默认顺序匹配 |
| link颜色        | `col`              | 用颜色矩阵或颜色向量指定，对于邻接矩阵和邻接列表不一样    |
| link透明度      | `transparency`     | 用0(不透明)到1(透明)的数字指定，如果要设置不同的透明度，则用法与颜色指定类似 |
| link边线宽      | `link.lwd`         | 用数字指定link弦边缘线宽度 |
| link边线型      | `link.lty`         | 用数字指定link弦边缘线的线型，与par参数一致 |
| link边线颜色    | `link.border`      | 指定link弦边缘线的颜色  |
| link弦可见      | `link.visible`     | 指定要显示的弦，用逻辑向量或矩阵指定，只显示逻辑值为正的弦  |
| sectors内的顺序 | `link.decreasing`  | 为逻辑值，表示指定link在sector内的顺序，需要先指定`link.sort = TRUE` |
| sectors外顺序   | `link.rank`        | 指定link在各个sector之间的顺序，用数字向量或矩阵指定，值大的后添加在表层  |
| 自我连接        | `self.link`        | 指定自我连接的类型，=1 或 =2  |
| 对称矩阵        | `symmetric`        | 为逻辑值，`symmetric = TRUE`表示只画邻接矩阵下三角部分，不包括对角线 |
| link方向        | `directional`      | =1或 =-1,设置方向后，link终点高度将缩短，可以调节缩短量  |
| link箭头        | `direction.type`   | 指定方向类型: `"arrows"`，`c("arrows", "diffHeight")`，`"big.arrow"`大箭头 |
| link高度        | `diffHeight`       | 指定link终点缩短量，可以为负数,必须先在`direction.type`中设定`diffHeight` |
| 窄弦丢弃        | `reduce`           | 从0到1的数字，表示link宽度小于弦总宽度百分比的link将不予显示,`circos.info()`可查看 |
| 轨道显示        | `annotationTrack`  | 表示指定要显示的轨道,`NULL`隐藏，`c("name", "grid", "axis")`标签，网格和刻度 |

### 外围sectors的顺序  
* 对于邻接矩阵，外围sector的顺序与`union(rownames(mat), colnames(mat))`一致，默认从3点钟方向顺时针旋转   
* 对于邻接列表，外围sector的顺序与`union(df[[1]], df[[2]])`一致  
* `order`参数调整外围sector的顺序，当然指定字符串向量的长度应与sectors的数量一致  
如图所示：  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

chordDiagram(mat, order = c("S1", "E1", "E2", "S2", "E3", "E4", "S3", "E5", "E6"))  # 使用order参数调整顺序，默认3点钟顺时针方向  
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/2018110710410265.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### 颜色调整 
通常外围sector分为2类，第1类代表邻接矩阵的行名或邻接列表的第一列，第2类代表邻接矩阵的列名和邻接列表的第2列， 
连接弦link就是将2类sectors连接起来， **默认连接弦link的颜色与第1类对象的颜色一致**，  
改变外围sector中第1类对象的颜色，连接弦的颜色也会随之改变  
* 外围sector的颜色可以用`chordDiagram(grid.col= )`参数调整，  
  指定的颜色向量最好有一个名称属性，该名称属性与secters名称一样，这样才能一一匹配，否则没有名称属性则按顺序匹配  
* 连接弦link的透明度可以用transparency参数调整，从0(完全不透明)到1(完全透明)，默认透明度为0.5  
* 连接弦link的参数可以用col参数调整，需要指定**颜色矩阵**(数据为邻接矩阵) 或**颜色向量**(数据为邻接列表)  
  可以用函数`rand_color()`产生随机颜色矩阵，可以在里面设置透明度参数，再指定透明度会被忽略   
  当相互作用relation为连续变量时，可以通过`colorRamp2()`产生连续的颜色向量，col参数也支持  
* 当数据是连接矩阵时，可以不提供颜色矩阵，link颜色指定还可以用颜色向量指定，使用参数`row.col`或`column.col`指定  
  仅仅提供与行名或列名长度相同的颜色向量，颜色向量可以用颜色名称，hex色值，甚至数字表示  
**调整sectors颜色和link透明度**  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=TRUE, fig.show='hold'}
library(circlize)

grid_col <-  c(S1 = "red", S2 = "green", S3 = "blue",
    E1 = "grey", E2 = "grey", E3 = "grey", E4 = "grey", E5 = "grey", E6 = "grey") # 构建颜色向量，指定名称属性，则按名称匹配
chordDiagram(mat, grid.col = grid_col, transparency = 0.7) # 调整外围sector颜色，增加透明度
chordDiagram(t(mat), grid.col = grid_col) # 按名称匹配，则link颜色与mat矩阵的列名一致，全变为灰色

```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104158697.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104214224.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### 调整link颜色及透明度
`colorRamp2(breaks, colors, transparency = 0, space = "LAB")` 离散色板连续化，space表示色彩空间  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=TRUE, fig.show='hold'}
library(circlize)

# 数据是邻接矩阵
col_mat <- rand_color(length(mat), transparency = 0.7) # 产生随机颜色矩阵，并指定透明度
dim(col_mat) <- dim(mat) # 以确保col_mat是一个矩阵
chordDiagram(mat, grid.col = grid_col, col = col_mat) # 设置link颜色，
circos.clear()

# 数据是邻接列表
cols <- rand_color(nrow(df), transparency = 0.7) 
chordDiagram(df, grid.col = grid_col, col = cols)
circos.clear()

# link为连续变量
col_fun <- colorRamp2(range(mat), c("#FFEEEE", "#FF0000"), transparency = 0.5) # 产生连续色块并指定透明度
chordDiagram(mat, grid.col = grid_col, col = col_fun)
circos.clear()

# 用数字指定link颜色
chordDiagram(mat, grid.col = grid_col, row.col = 1:3, transparency = 0.7) # 用数字向量指定颜色，向量长度与连接矩阵的行数相同
chordDiagram(mat, grid.col = grid_col, column.col = 1:6, transparency = 0.7) # 用数字向量指定颜色，向量长度与连接矩阵的列数相同
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104312376.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104334330.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104356542.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104407629.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104427810.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)

### link边线宽，边线型，边线颜色
* link,lwd 参数调整link边缘线宽度    
* link.lty 参数调整link边缘线线型  
* link.border 参数调整link边缘线的颜色  
* 当数据是邻接矩阵时，这3个参数均可以用长度为1的向量指定，或矩阵  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

# 用长度的1的向量指定
chordDiagram(mat, grid.col = grid_col, link.lwd = 2, link.lty = 2, link.border = "red") # 指定link边线宽度，边线线型，边线颜色
circos.clear()

# 用矩阵指定
lwd_mat <- matrix(1, nrow = nrow(mat), ncol = ncol(mat)) # 元素为1的矩阵，其维度与源数据mat一致
lwd_mat[mat > 12] <- 2 # relation > 12,则加宽link边线
border_mat <- matrix(NA, nrow = nrow(mat), ncol = ncol(mat)) # 元素为NA的矩阵，其维度与源数据mat一致
border_mat[mat > 12] <- "red" # relation > 2，则为红色边缘线
chordDiagram(mat, grid.col = grid_col, link.lwd = lwd_mat, link.border = border_mat) # 指定link边缘线宽度，边缘线颜色
circos.clear() 

# 参数矩阵维度与数据源不一致,则改变部分颜色,必须按名称属性匹配
border_mat2 <- matrix("black", nrow = 1, ncol = ncol(mat)) # 生成1行的矩阵，其宽与数据源mat一致
rownames(border_mat2) <- rownames(mat)[2] # 将mat第2个行名赋值给border_mat2，则只会改变第mat第2行的边缘线颜色
colnames(border_mat2) <- colnames(mat) # 赋值列名，与数据源mat一致
chordDiagram(mat, grid.col = grid_col, link.lwd = 2, link.border = border_mat2) #
circos.clear()

# 参数矩阵还可以设置为特殊的3列格式，前2列分别对应数据源的行名称和列名称，第3列为参数列，相当于邻接列表格式的参数矩阵
lty_df <- data.frame(c("S1", "S2", "S3"), c("E5", "E6", "E6"), c(1, 2, 3)) # link边缘线分别为1, 2, 3
lwd_df <- data.frame(c("S1", "S2", "S3"), c("E5", "E6", "E4"), c(2, 2, 2)) # link边线线宽为2
border_df <- data.frame(c("S1", "S2", "S3"), c("E5", "E6", "E4"), c(1, 1, 1)) # link边缘线颜色为1
chordDiagram(mat, grid.col = grid_col, link.lty = lty_df, link.lwd = lwd_df, link.border = border_df) 
circos.clear()

# 当数据源是邻接列表时，只需要指定跟源数据一样行数的向量，特别方便
chordDiagram(df, grid.col = grid_col, 
             link.lty = sample(1:3,nrow(df), replace = TRUE),
             link.lwd = runif(nrow(df)) * 2, 
             link.border = sample(0:1, nrow(df), replace = TRUE))
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104509726.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104519906.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104531380.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/2018110710454140.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104550115.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### link弦可见
在需要强调某些relation时，需要高亮对应的弦，一般有4种高亮方式：  
* 设置弦边缘颜色(前面已经介绍了)，  
* 设置不同的透明度，  
* 或只显示某些弦，其它全是透明的灰色  
* 通过`link.visible`参数指定要显示的弦，其它都不显示，可以用逻辑矩阵(对于邻接矩阵)或逻辑向量(对于邻接列表)进行指定  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

# 通过指定不同的颜色进行高亮
chordDiagram(mat, grid.col = grid_col, row.col = c("#FF000080", "#00FF0010", "#0000FF10"))
circos.clear()

# 通过指定透明色给某些在范围之外的relation 
col_mat[mat < 12] <- "#00000000" # relation < 12则变为透明色
chordDiagram(mat, grid.col = grid_col, col = col_mat) # 
circos.clear()

# 通过函数同时指定透明色和高亮色，对邻接列表数据源也适用
col_fun <- function(x) {ifelse(x < 12, "#00000000", "#FF000080") }# relation小于12则为透明色，反之为#FF000080石榴红
chordDiagram(mat, grid.col = grid_col, col = col_fun, transparency = 0.7)
circos.clear()

# 事实上，所有颜色矩阵或颜色生成函数中色彩都是绘制在图形中的，只是程序内部将其透明度设置为了1，
# 通过3列特殊数据框指定的颜色，其缺失的颜色的relation将不会画出
col_df <- data.frame(c("S1","S2", "S3"), c("E5", "E6", "E4"), 
                     c("#FF000080", "#00FF0080", "#0000FF80"))
chordDiagram(mat, grid.col = grid_col, col = col_df) 
circos.clear()

# 对于邻接列表数据源，高亮弦调整更简单，只需要设置要高亮的颜色，其它为透明色就行了
cols <- rand_color(nrow(df))
cols[df[[3]] < 10] <- "#00000000" # 将df中第3列，即relation列，列值小于10的都更新为透明色HEX色值
chordDiagram(df, grid.col = grid_col, col = cols)

# 通过link.visible参数调整
cols <- rand_color(nrow(df))
chordDiagram(df, grid.col = grid_col, link.visible = df[[3]] >= 10) # 只显示df第3列大于10的弦
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104613960.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104624699.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104641150.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104654161.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104720580.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104733716.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### 弦在同一个sector上的顺序调整  
有时候为了方便查询，需要将弦link按宽窄顺序排列，可以用参数`link.sort`和`link.decreasing`设定:  
* `link.sort = TRUE` 表示设置顺序，默认为了好看自动调整弦的顺序,指定该参数后，`link.decreasing` 参数才有效   
* `link.decreasing = TRUE/FALSE` 表示降序或升序，默认顺时针，降序表示宽度沿顺时针方向逐渐下降  

```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

chordDiagram(mat, grid.col = grid_col, link.sort = TRUE, link.decreasing = TRUE) #按弦宽度下降排列,则弦宽沿顺时针方向逐渐下降
title("link.sort = TRUE, link.decreasing = TRUE",cex = 0.8) # 添加标题
circos.clear()

chordDiagram(mat, grid.col = grid_col, link.sort = TRUE, link.decreasing = FALSE) # 弦宽沿顺时针方向逐渐增大
title("link.sort = TRUE, link.decreasing = FALSE", cex = 0.8)
circos.clear()

```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104759351.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104808923.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### 弦在多个sectors上的顺序调整
添加弦link的顺序对于视觉效果影响很大，默认安装数据源的顺序进行添加，可以用参数`link.rank`参数调整弦的添加顺序  
* 通常给邻接列表增加一列，为relation的秩，然后用秩指定`link.rank`参数，则relation越小，秩越大，  
  则`link.rank`参数先添加最大秩对应的弦，即最小的relation,于是relation越大，越出现在表层  
* 反之，如果要将宽的relation调整到下面，则直接用relation列指定`link.rank`参数  

```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

# 邻接矩阵数据源，求矩阵的秩，然后指定给link.rank参数
chordDiagram(mat, grid.col = grid_col, transparency = 0, link.rank = )# 设置透明度为0，方便观察
chordDiagram(mat, grid.col = grid_col, transparency = 0, link.rank = rank(mat)) # 用mat中的秩进行排序，秩最大先添加
circos.clear()

# 邻接列表数据源，对relation列求秩，然后指定给link.rank参数
chordDiagram(df, grid.col = grid_col, transparency = 0, link.rank = rank(df[[3]])) # 第3列为relation列，求秩
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104842107.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104851402.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### 自我连接
当信息需要复制的时候，可以使用自我连接，使用参数`self.link`指定，用1或2指定，分别代表2种情形  
这个用在基因或细胞复制的可视化中，其它用的比较少  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

df2 <- data.frame(start = c("a", "b", "c", "a"), end = c("a", "a", "b", "c"))
chordDiagram(df2, grid.col = 1:3, self.link = 1) # 
chordDiagram(df2, grid.col = 1:3, self.link = 2)
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104907693.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104916381.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### 对称矩阵 
当数据源是对称矩阵时，通过参数`symmetric = TRUE`，只有矩阵下三角部分relation会被可视化(不包括对角线)  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

mat3 <- matrix(rnorm(25), 5) # 生成25个均匀分布的随机数, 5行排列
colnames(mat3) <- letters[1:5] 
cor_mat <- cor(mat3) # 求相关系数,则变为对称矩阵

col_fun <- colorRamp2(c(-1, 0, 1), c("green", "white", "red"))
chordDiagram(cor_mat, grid.col = 1:5, symmetric = TRUE, col = col_fun)
title("symmetric = TRUE") # 增加标题
circos.clear()

chordDiagram(cor_mat, grid.col = 1:5, col = col_fun)
title("symmetric = FALSE")
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/2018110710493732.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107104949909.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### 弦link的方向
很多时候，数据源是有方向性的，如城市的航班来往，贸易来往，  
* 对于邻接矩阵，本身就可以是有方向性的，如以行名为方向的起点，或以列名为方向的起点  
* 对于邻接列表，通常用前2列的列的顺序表示方向，从第1列到第2列，或从第2列到1列  
用`directional`指定弦的方向，`directional = 1`或`directional = -1`：
* 对于邻接矩阵，1 表示从行名到列名，-1则反之  
* 对于邻接列表，1 表示从从第1列到第2列，-1则反之  
不设置方向属性时，弦的高度都相等，即与sectors之间的gap都相等，当设置方向后，则其中一端会缩短一些，如果短的地方不对，则反转方向  
如果缩短的量不够，则可以通过`diffHeight`参数设置， 也可以设置负数  
有时候，数据源的行名或列名可能存在相同值，这时候设置方向就很容易区分，
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

par(mfrow = c(1, 3)) # 设置绘图环境，多图布局，1行3列布局

chordDiagram(mat, grid.col = grid_col, directional = 1) # 结束端要短一些
chordDiagram(mat, grid.col = grid_col, directional = 1, diffHeight = uh(5, "mm")) # 设定缩短量为5mm， uh表示传递单位  
chordDiagram(mat, grid.col = grid_col, directional = -1) # 反转方向，这行名对应的端要短一些
circos.clear()

```
![在这里插入图片描述](https://img-blog.csdnimg.cn/2018110710502460.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)

**数据源的行名和列名存在相同值**  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=TRUE, fig.show='hold'}
library(circlize)

mat2 <- matrix(sample(100, 35), nrow = 5)
rownames(mat2) <- letters[1:5]
colnames(mat2) <- letters[1:7]
mat2
chordDiagram(mat2, grid.col = 1:7, directional = 1, row.col = 1:5)
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/2018110710504667.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
**如果不需要显示自我连接的弦**  
则更改数据源中对应的值，使该值为0  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

mat3 <- mat2 
for (cn in intersect(rownames(mat3), colnames(mat3))) { 
  mat3[cn, cn] <- 0 # 将行名和列名相同的值更改为0
  
}
mat3 

chordDiagram(mat3, grid.col = 1:7, directional = 1, row.col = 1:5) # 设置弦方向为从行名到列名，设置弦颜色
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107105100884.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### link方向、箭头及高度调整
弦link有方向属性，就可以增加箭头，有2个参数可以增加箭头  
* `direction.type = "arrows"` 给弦增加带箭头的曲线，曲线位于弦的中心线上，默认给所有弦增加箭头  
* `link.arr.col` 给部分弦增加带箭头的曲线，并指定箭头的颜色，指定方式跟颜色的指定类似, 必须设置`direction.type = "arrows"`参数  
* `link.arr.length` 指定带箭头曲线中，箭头的长度  
* `link.arr.type` 指定箭头类型，可以用`link.arr.type = "big.arrow"` 产生大尺寸箭头，将箭头和箭杆合二为一    
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

arr_col <- data.frame(c("S1", "S2", "S3"), c("E5", "E6", "E4"), 
                      c("black", "black", "black")) # 生成箭头的颜色3列特征数据框
chordDiagram(mat, grid.col = grid_col, directional = 1,
             link.arr.col = arr_col, direction.type = "arrows", link.arr.length = 0.2) 
circos.clear()

# 同时设置箭头和弦高diffHeight
chordDiagram(mat, grid.col = grid_col, directional = 1, 
    direction.type = c("diffHeight", "arrows"), # 同时设置箭头和弦高
    link.arr.col = arr_col, link.arr.length = 0.2)
circos.clear()

par(mfrow = c(1, 2))
# 指定箭头类型为大箭头
matx <-  matrix(rnorm(64), 8)

chordDiagram(matx, directional = 1, direction.type = c("diffHeight", "arrows"),
    link.arr.type = "big.arrow") # 大箭头，箭头和箭杆合二为一
circos.clear()

# 大箭头加调整弦高diffHeight
chordDiagram(matx, directional = 1, direction.type = c("diffHeight", "arrows"),
    link.arr.type = "big.arrow", diffHeight = -uh(2, "mm")) # 设置弦高为-2mm
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107105125781.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107105141670.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107105155120.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### 窄弦丢失 
对于relation值相对太小，其对应的弦的宽度也非常小，对于这种极小值，在程序绘图时，会自动去除，不给予显示  
可以通过`reduce`参数控制link宽度的下限，超出该范围的将不显示，  
`reduce`参数为0到1的数字(包含0)， 表示占所有弦宽度之和的百分比  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

# 默认移除小比例值
mat <- matrix(rnorm(36), 6, 6)
rownames(mat) <-  paste0("R", 1:6)
colnames(mat) <- paste0("C", 1:6)
mat[2, ] <- 1e-10 # 将第2行所有值改成很小的值
mat[, 3] <- 1e-10 # 将第3列所有值改成很小的值

chordDiagram(mat)
circos.info() # 显示绘图的对象，不包含第2行的行名(R2)和第3列的列名(C3)，则表示被移除了
circos.clear()

# reduce参数调整
mat[2, ] <- 1e-2
chordDiagram(mat, reduce = 1e-3) # 控制reduce参数比C2小，则C2行不会被移除
circos.info()
circos.clear()
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107105456644.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107105228175.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181107105252971.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)
### 轨道调整
`chordDiagram()`默认创建2个外围轨道，一个标签(列名和行名)轨道，一个带有刻度线的网格轨道   
`circos.info()`显示的"All your tracks"下面就是所有的轨道，  
* `annotationTrack`参数可以调整轨道，从`c("name", "grid", "axis")`中指定任意值，可以多个值，表示只显示指定的轨道， 
* `annotationTrackHeight`参数可以指定轨道环高，用数字向量指定，向量长度与`annotationTrack`参数一致  
```{r,max.print = 18, rows.print = 6, tidy=TRUE, message=FALSE, results="hold", warning=FALSE, cache=FALSE, fig.show='hold'}
library(circlize)

par(mfrow = c(1, 3)) # 多图布局，分3列排版
chordDiagram(mat, grid.col = grid_col, annotationTrack = "grid") # 只显示网格，不显示刻度线和标签轨道
chordDiagram(mat, grid.col = grid_col, annotationTrack = c("name", "grid"), # 指定显示标签和网格轨道
    annotationTrackHeight = c(0.03, 0.01)) # 指定标签轨道和网格轨道的环高  

chordDiagram(mat, grid.col = grid_col, annotationTrack = NULL) # 移除所有轨道
circos.clear()

```
![在这里插入图片描述](https://img-blog.csdnimg.cn/2018110710530770.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyODEwOQ==,size_16,color_FFFFFF,t_70)


