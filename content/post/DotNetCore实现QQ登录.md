---
title: "DotNetCore实现QQ登录"
date: 2026-04-05T22:38:00+08:00
draft: false
summary: "在 .Net Core 中使用 Microsoft.AspNetCore.Authentication.QQ 组件实现 QQ 第三方登录，记录从 QQ 互联申请到代码实现的完整过程及踩坑经验"
tags: [".NetCore", "QQ登录", "OAuth2.0", "认证"]
---

写这篇文章的目的是因为现在网上找不到比较好的、比较全的、看完一篇文章就可以搞定这个功能的文章，所以我要在这里借鉴和总结一下实现这个QQ登录遇到的坑和问题。

<!--more-->

## 一、首先要知道自己要干嘛

现在我们知道要实现QQ登录，那应该怎么去做呢，当然要先去了解QQ提供给我们的一种登录方式，在这里我找到了QQ互联（QQ互联网址），在这里要吐槽一下腾讯这么大个厂，QQ互联这套系统做的是真**，真难用，我在这里遇到了很多坑，从注册填写申请信息到审核等等，差不多用了半个月的时间，给大家讲一下这里遇到的坑，希望大家可以及时的躲开，不要在这上面浪费时间。

在这里需要审核两次

1：第一次是对你个人开发者信息的审核，需要填写身份证号，上传手持身份证正面的照片（这里要注意，不能使用手机的前摄像头，会有镜像，拍出来身份证上的信息都是反的，腾讯审核不通过），联系地址一定要精确到户，腾讯要求的，我也不知道为啥，反正我写了一个模糊不给通过。

2：第二次是对应用的审核，不管你是网站，还是app，都要在这里创建相对应的应用。这里要注意，网站名称一定要写备案时的网站名称，不然审核不给通过。

![QQ互联应用创建](/images/DotNetCore实现QQ登录/16104336_1.png)

创建完成后需要填写网站地址，也就是备案的地址，网站回调地址可以写多个，用分号隔开。主办单位名称，我写到这里的时候就很懵逼，这是个啥意思，随便写了个昵称审核不给通过，后来咨询客服人员才知道这里要写备案时的主办单位，如果是个人肯定是自己的真是姓名，如果是单位就写单位名称。

这些做完之后，审核需要一天时间，静静的等着就行了，如果审核不通过系统会返回原因，根据原因修改就可以了，不明白的还可以咨询腾讯客服（在网站的下方），在这里我又要吐槽下这个互联网站（开发者信息审核的时候遇到的一个坑，审核不通过在这里是看不到原因的，就很莫名其妙，不知道哪里有问题无从下手，还是我多次咨询客服后解决的，后来才知道在另一个网站也能填写，腾讯开放平台网址）

审核通过后，我们就可以看QQ互联这个接口的说明文档了（ QQ互联文档地址 ），通过文档我们了解到，QQ登录用了一种协议叫OAuth2.0，这是啥？

![OAuth2.0介绍](/images/DotNetCore实现QQ登录/16104336_2.png)

原来如此，明白了，那么我咋用，其实文档里写的很清楚啦，这里我就不多说了，再来看看API文档，看了一遍好像有点不太聪明的样子，不过没关系，不会的东西我们百度呀，经过百度一圈后我大致发现，有两种路线可以实现这个QQ登录：第一种是通过访问API地址，完全的手撸代码，在URL里各种拼接参数，请求URL之类的，给个链接地址看两眼<https://blog.csdn.net/weixin_30316097/article/details/101068005>；还有一种是通过咱们的Nuget组件（这个就很灵性，我喜欢）,Microsoft.AspNetCore.Authentication.QQ ，这种方式撸的代码就比较少了，而且也比较高级。下面我们就用这种方式来给大家演示如何实现QQ登录。

## 二、.NetCore怎么实现QQ登录

### 1.在Web项目中引用Nuget包

Microsoft.AspNetCore.Authentication.QQ，这里要注意了，组件要求2.2以上的框架。

![Nuget安装](/images/DotNetCore实现QQ登录/16104336_3.png)

### 2.在项目的配置文件appsetting.json中添加如下的配置

```json
{
  "Authentication": {
    "QQ": {
      "AppId": "你的AppId",
      "AppKey": "你的AppKey"
    }
  }
}
```

在这里我发现在他的代码中还需要一块代码，看下图

![配置代码](/images/DotNetCore实现QQ登录/16104336_4.png)

### 3.重点来了，需要在Startup.cs文件中注册认证服务

```csharp
//注册认证服务
services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
.AddCookie(options =>
{
    //这里填写一些配置信息，默认即可
}) //添加Cookie认证
.AddQQ(qqOptions =>
{
    qqOptions.AppId = Configuration["Authentication:QQ:AppId"]; //QQ互联申请的AppId
    qqOptions.AppKey = Configuration["Authentication:QQ:AppKey"]; //QQ互联申请的AppKey
    qqOptions.CallbackPath = "/user/callback"; //QQ互联回调地址
    //自定义认证声明
    qqOptions.ClaimActions.MapJsonKey(MyClaimTypes.QQOpenId, "openid");
    qqOptions.ClaimActions.MapJsonKey(MyClaimTypes.QQName, "nickname");
    qqOptions.ClaimActions.MapJsonKey(MyClaimTypes.QQFigure, "figureurl_qq_1");
    qqOptions.ClaimActions.MapJsonKey(MyClaimTypes.QQGender, "gender");
});
```

这块可以直接拿来用，上面的CallbackPath 一定要写上面QQ互联申请时的地址。完全的复制粘贴后我发现MyClaimTypes.QQOpenId没有引用会报错，然后我开始研究这是个什么东西，知道这个参数是啥，就要明白参数外面的方法是啥意思，我研究了半天ClaimActions.MapJsonKey，这个方法的摘要是这么说的：

从具有给定键名的json用户数据中选择一个顶级值，并将其作为声明添加。如果找不到密钥或值为空，则不执行操作。

从而我发现MyClaimTypes.QQOpenId这个的值应该是个字符串，竟然是个字符串的话，那这应该是个静态类，直接引用里面的字段。于是我就创建了MyCalimTypes类。

就很棒，目前来说不报错了。

不要忘了使用认证中间件：在Configure方法添加以下代码。

```csharp
//使用验证中间件
app.UseAuthentication();
```

### 4.真正关键的时刻来了

下面我们就要开始写登录功能了

创建一个UserController控制器，在UserController中需要写两个Action，一个用来触发QQ登录，一个用来处理登录成功后的逻辑。例如：

```csharp
public IActionResult Login(string provider = "QQ", string returnUrl = null)
{
    //第三方登录成功后跳转的地址
    var redirectUrl = Url.Action(nameof(ExternalLoginCallbackAsync), new { returnUrl });
    var properties = new AuthenticationProperties()
    {
        RedirectUri = redirectUrl
    };
    return Challenge(properties, provider);
}

[Authorize]
public async Task ExternalLoginCallbackAsync(string returnUrl = null)
{
    //QQ认证后会默认登录，如果你想自定义登录，可以先注销第三方登录的身份
    //await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);

    string openId = "", name = "", figure = "", gender = "";
    //从当前登录用户的身份声明中获取信息（是否有些眼熟，MyClaimTypes就是在Startup里面自定义的那些）
    foreach (var item in HttpContext.User.Claims)
    {
        switch (item.Type)
        {
            case MyClaimTypes.QQOpenId:
                openId = item.Value;
                break;
            case MyClaimTypes.QQName:
                name = item.Value;
                break;
            case MyClaimTypes.QQFigure:
                figure = item.Value;
                break;
            case MyClaimTypes.QQGender:
                gender = item.Value;
                break;
            default:
                break;
        }
    }

    //获取到OpenId后进行登录或者注册（以下作为示范，不要盲目复制粘贴）
    if (!openId.IsNullOrEmpty())
    {
        //去数据库查询该QQ是否绑定用户
        User user = await _dbContext.User.Where(s => s.QQOpenId == openId).FirstOrDefaultAsync();

        if (user != null)
        {
            #region 存在则登陆

            var identity = new ClaimsIdentity(CookieAuthenticationDefaults.AuthenticationScheme);
            identity.AddClaim(new Claim(ClaimTypes.Sid, user.Id.ToString()));
            identity.AddClaim(new Claim(ClaimTypes.Name, user.Name));
            identity.AddClaim(new Claim(MyClaimTypes.Avator, user.Avatar));

            await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(identity), new AuthenticationProperties
            {
                IsPersistent = true,
                ExpiresUtc = DateTimeOffset.Now.Add(TimeSpan.FromDays(int.Parse(Configuration["AppSettings:LoginExpires"]))) // 有效时间
            });

            user.LastLoginIP = HttpContext.GetUserIP();
            user.LastLoginTime = DateTime.Now;

            //更新登录信息
            _dbContext.User.Update(user);
            await _dbContext.SaveChangesAsync();

            #endregion

            if (returnUrl != null)
                return Redirect(returnUrl);
            else
                return RedirectToAction("index", "home");
        }
        else
        {
            User userModel = new User();
            userModel.QQOpenId = openId;
            userModel.Name = name;
            userModel.Avatar = figure;
            userModel.Gender = gender;
            userModel.CreateTime = DateTime.Now;

            //注册
            await _dbContext.User.AddAsync(userModel);

            if (await _dbContext.SaveChangesAsync() > 0)
            {
                #region 注册后自动登陆

                var identity = new ClaimsIdentity(CookieAuthenticationDefaults.AuthenticationScheme);
                identity.AddClaim(new Claim(ClaimTypes.Sid, userModel.Id.ToString()));
                identity.AddClaim(new Claim(ClaimTypes.Name, userModel.Name));
                identity.AddClaim(new Claim(MyClaimTypes.Avator, userModel.Avatar));

                await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(identity), new AuthenticationProperties
                {
                    IsPersistent = true,
                    ExpiresUtc = DateTimeOffset.Now.Add(TimeSpan.FromDays(int.Parse(Configuration["AppSettings:LoginExpires"]))) // 有效时间
                });

                userModel.LastLoginIP = HttpContext.GetUserIP();
                userModel.LastLoginTime = DateTime.Now;

                //更新登录信息
                _dbContext.User.Update(userModel);
                await _dbContext.SaveChangesAsync();

                #endregion

                if (returnUrl != null)
                    return Redirect(returnUrl);
                else
                    return RedirectToAction("index", "home");
            }
            else
                throw new Exception("Add User failed");
        }
    }
    else
        throw new Exception("OpenId is null");
}
```

![AuthenticationProperties](/images/DotNetCore实现QQ登录/16104336_5.png)

AuthenticationProperties这是个啥，new了一下，说明是个对象，return Challenge 又是个啥，返回了个啥？咱也没见过，那就百度吧。百度了半天也没找到满意的解释，就去bing一下吧，后来我发现有趣的事情来了，上链接：<https://www.cnblogs.com/OpenCoder/p/10310839.html>，这是一篇国外的文章，国人翻译的，就有些内容不好懂，这个地方就只能意会了。毕竟我是一只菜鸟。

![Challenge解释](/images/DotNetCore实现QQ登录/16104336_6.png)

通过研究发现，大概就是个重定向的东西，一会儿把赋值粘贴的代码的错误都解决了，调试下看看怎么走的。

在这里这坨静态类的字段又出来了，后来发现这个地方不能用静态变量，我又把变量改成了常量const，错误接触，Nice。

![MyClaimTypes](/images/DotNetCore实现QQ登录/16104336_7.png)

接下来就是各种引用，引用完了之后发现还是一堆错，认真的看看代码，这块代码是人家自己插入修改用户的方法，这里可以先删掉，后面用我们自己的就可以了

![用户方法](/images/DotNetCore实现QQ登录/16104336_8.png)

这块代码大概的逻辑就是，用户登录后，先根据OpenId去库里查看看有没有这个用户，如果没有的话，先把用户的信息存到库里，再把用户的信息写到缓存里并且登录，再把用户当前的登录IP和登录时间记录到库里； 如果有的话，把用户的信息写到缓存里并且登录，接着记录下用户当前的登录IP和登录时间 。这块没啥难的，我们继续。

后台的代码写的差不多了，我们给前台View一个链接，请求我们刚写的这个方法。

### 5.开始使用

在页面上放置触发QQ登录的按钮，如：

```html
<a href="/user/login?provider=QQ&returnUrl=@returnUrl" >
    <i class="fa fa-qq"></i>
</a>
```

returnUrl最好给用户操作的当前页面，这样登录之后还是返回到用户浏览的页面，用户体验比较好，我是这么写的。

### 6.结语

该案例使用的是微软的认证组件，上文提到的provider需要注意，QQ登录必须写QQ。

微软自身提供了Microsoft账号、Google账号等国外账号的认证组件，用法应该和上述类似，有兴趣的去Github下载asp.net源码看看呗。

此外Microsoft.AspNetCore.Authentication.QQ这个包在Github上也有源码，大家可以看看别人是怎么实现的，也能够知晓provider必须写QQ的原因，顺便自己封装个微博、微信登录也是可以的。

在这里不落阁的文章就结束了，我们也开发的差不多了，调试一把。

![QQ登录按钮](/images/DotNetCore实现QQ登录/16104336_9.png)

点击QQ图标，跳转到QQ的登录页面，就很Nice，我们成功了。

![QQ登录页面](/images/DotNetCore实现QQ登录/16104336_10.png)

登录后返回到当然页面，应该是登录功能了，用户数据也写到缓存里了，但是页面没有任何变化，那是当然的啦，我们还没有开发呀！

我们可以把登录用户的QQ昵称和头像显示在右上角，就像这样。

![用户信息显示](/images/DotNetCore实现QQ登录/16104336_11.png)

嗯~不错，高端大气上档次，上代码。

```html
@if (User.Identity.Name != null)
{
    <li class="layui-nav-item">
        <a class="fly-nav-avatar" href="~/user/out?returnUrl=@this.Context.Request.Path.Value">
            @User.Identity.Name
            <cite class="layui-hide-xs">
            </cite>
            <img src="@User.Claims.Where(p => p.Type == "avator").FirstOrDefault()?.Value">
        </a>
        <dl class="layui-nav-child">
            <dd style="color:#5FB878;text-align:center;"><span>点击头像注销</span></dd>
        </dl>
    </li>
}
else
{
    <li class="layui-nav-item">
        <a href="~/user/login?provider=QQ&returnUrl=@this.Context.Request.Path.Value"><i class="layui-icon layui-icon-login-qq" style="font-size:30px;"></i></a>
    </li>
}
```

因为我是个菜鸟，所以我不知道怎么从缓存里拿到用户登录的数据，后来我发现有个User属性，那就试试吧，User里还可以点出Identity，还可以点出Name，那就很完美了，用户的名字我们不就有了吗，那头像呢？咋搞？

不急，我们继续看代码，发现这个Claims很熟悉，因为后台代码里我们把用户的数据通过这种方式写到了缓存里，所以我猜想应该从这里能拿到头像，那就试试。再调试一下。

Nice，我们又成功了。

![登录成功](/images/DotNetCore实现QQ登录/16104336_12.png)

登录后我发现没有退出啊，上退出代码

```csharp
public async Task<IActionResult> Out(string returnUrl = null)
{
    await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
    if (returnUrl != null)
        return Redirect(returnUrl);
    else
        return RedirectToAction("index", "home");
}
```

如果你足够细心的话，前台代码其实刚刚我已经放到上面了，就在这里

最后调试一下，注销功能也做好了。

到这里我们.Net Core框架下实现QQ登录就已经做好了。其实你会发现，解决问题的思路很重要，代码不可能一下子就写完，当我们触碰到新领域的时候，只能跌跌撞撞的不断去摸索，不断去尝试，我也是第一次接触这个QQ登录，但经过我的不懈努力，不也是做出来了，而且自己还会有些许的小成就呢（臭美）。

在这里总结了下遇到的问题，希望可以帮助到大家。
