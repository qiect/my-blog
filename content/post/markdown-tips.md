---
title: "Markdown 写作技巧"
date: 2026-06-05T14:00:00+08:00
draft: false
summary: "掌握 Markdown 语法，提升博客写作效率"
tags: ["Markdown", "写作", "技巧"]
---

## Markdown 简介

Markdown 是一种轻量级标记语言，让你可以用简单的语法格式化文本。

<!--more-->

## 基础语法

### 标题

```markdown
# 一级标题
## 二级标题
### 三级标题
#### 四级标题
##### 五级标题
###### 六级标题
```

### 强调

```markdown
*斜体* 或 _斜体_
**粗体** 或 __粗体__
***粗斜体*** 或 ___粗斜体___
```

### 列表

无序列表：

```markdown
- 项目 1
- 项目 2
  - 子项目 2.1
  - 子项目 2.2
```

有序列表：

```markdown
1. 第一项
2. 第二项
3. 第三项
```

### 链接和图片

```markdown
[链接文本](https://example.com)
![图片描述](image-url.png)
```

### 代码

行内代码：`` `code` ``

代码块：

````markdown
```python
def hello():
    print("Hello, World!")
```
````

### 引用

```markdown
> 这是一段引用
> 可以多行
```

### 表格

```markdown
| 列1 | 列2 | 列3 |
|-----|-----|-----|
| A   | B   | C   |
| D   | E   | F   |
```

## Hugo 扩展

### Front Matter

```yaml
---
title: "文章标题"
date: 2026-06-05
draft: false
tags: ["标签1", "标签2"]
summary: "文章摘要"
---
```

### 短代码

```markdown
{{</* details "点击展开" */>}}
隐藏内容
{{</* /details */>}}
```

## 写作建议

1. 使用清晰的标题层级
2. 适当使用列表和强调
3. 代码块指定语言以获得语法高亮
4. 添加适当的空行提高可读性
