# 发现功能模块 - 项目结构说明

## 完整目录结构

```
lib/
├── main.dart                                    # 主入口文件，配置路由
├── config/                                      # 配置文件
│   ├── app_config.dart                         # 应用配置（API地址等）
│   └── app_routes.dart                         # 路由配置，支持宿主App跳转
├── models/                                      # 数据模型
│   ├── tab_model.dart                          # Tab配置模型
│   ├── banner_model.dart                       # Banner轮播图模型
│   ├── diamond_model.dart                      # 金刚区图标模型
│   └── article_model.dart                      # 文章/资讯模型
├── services/                                    # 服务层（网络请求）
│   └── discover_service.dart                   # 发现页面服务
├── utils/                                       # 工具类
│   ├── time_util.dart                          # 时间工具类（格式化显示）
│   └── count_util.dart                         # 数量工具类（格式化显示）
├── providers/                                   # 状态管理（Provider）
│   └── (暂无，状态管理在views/discover/discover_provider.dart)
└── views/                                       # 视图层
    ├── discover/                                # 发现模块
    │   ├── discover_page.dart                  # 发现主页（Tab栏+滑动切换）
    │   ├── discover_provider.dart              # 发现页面状态管理
    │   ├── components/                          # 组件
    │   │   ├── discover_app_bar.dart           # 顶部AppBar（搜索+消息）
    │   │   ├── discover_tab_bar.dart           # Tab栏组件（支持滑动）
    │   │   ├── banner_carousel.dart            # Banner轮播图组件
    │   │   ├── diamond_grid.dart               # 金刚区组件（一行5个，可滑动）
    │   │   └── article_list.dart               # 文章列表组件（瀑布流）
    │   └── pages/                               # Tab页面
    │       ├── recommend_page.dart             # 推荐页面（Banner+金刚区+瀑布流）
    │       ├── community_page.dart             # 社区页面（精选/最新/关注+发帖按钮）
    │       ├── club_page.dart                  # 俱乐部页面
    │       ├── smart_drive_page.dart           # 智驾页面（Banner+功能区）
    │       ├── activity_page.dart              # 活动页面
    │       ├── news_page.dart                  # 资讯页面
    │       ├── circle_page.dart                # 圈子页面
    │       ├── live_page.dart                  # 直播页面
    │       └── reputation_page.dart            # 口碑页面
    ├── post/                                    # 发帖功能
    │   └── post_page.dart                      # 发帖页面（文字/图片/视频，草稿箱）
    └── video/                                   # 视频播放
        └── video_player_page.dart              # 视频播放页（缓存+上下滑动）

assets/
├── images/                                      # 图片资源
└── icons/                                       # 图标资源
```

## 核心功能实现

### 1. 工具类 (utils/)

#### time_util.dart - 时间格式化
- 一分钟内显示"刚刚"
- 一小时内显示"XX分钟前"
- 一天内显示"XX小时前"
- 超过24小时显示"月-日 时:分"
- 超过一年显示"年-月-日 时:分"

#### count_util.dart - 数量格式化
- 不足1万按实际数量显示
- 超过1万显示为"X万+"或"X.X万+"（1位小数，不四舍五入）

### 2. 数据模型 (models/)

#### tab_model.dart
- Tab配置：id、name、visible、sort、route

#### banner_model.dart
- Banner配置：id、imageUrl、linkUrl、title、sort

#### diamond_model.dart
- 金刚区配置：id、name、iconUrl、linkUrl、visible、sort

#### article_model.dart
- 文章/资讯：id、title、imageUrl、videoUrl、作者信息、点赞/收藏数、置顶/精选标记等

### 3. 页面实现 (views/)

#### discover_page.dart - 发现主页
- 实现Tab栏和PageView滑动切换
- 支持手势左右滑动切换Tab
- 支持路由跳转指定Tab

#### recommend_page.dart - 推荐页面
- Banner轮播图
- 金刚区（一行5个，最多2行，可滑动）
- 功能组件区（热门话题、车型圈列表、专题合集等）
- 精彩资讯瀑布流

#### community_page.dart - 社区页面
- 精选/最新/关注三个Tab
- 右下角悬浮发帖按钮

#### post_page.dart - 发帖页面
- 支持文字帖、图片帖、视频帖
- 支持图文混排
- 草稿箱功能

#### video_player_page.dart - 视频播放页
- 支持视频缓存播放
- 上下手势滑动切换视频

## 路由配置

### 路由表 (app_routes.dart)
- `/discover` - 发现主页
- `/discover/recommend` - 推荐Tab
- `/discover/community` - 社区Tab
- `/discover/club` - 俱乐部Tab
- `/discover/smart-drive` - 智驾Tab
- `/discover/activity` - 活动Tab
- `/discover/news` - 资讯Tab
- `/discover/circle` - 圈子Tab
- `/discover/live` - 直播Tab
- `/discover/reputation` - 口碑Tab
- `/post` - 发帖页面
- `/video` - 视频播放页（支持query参数：url、title、list）

### 宿主App跳转示例
```dart
// 跳转到发现主页
context.go('/discover');

// 跳转到推荐Tab
context.go('/discover/recommend');

// 跳转到指定Tab（通过tabId）
context.go('/discover?tabId=smart-drive');

// 跳转到指定Tab（通过tabIndex）
context.go('/discover?tabIndex=3');
```

## 下一步工作

1. **安装依赖**：运行 `flutter pub get`
2. **配置API**：在 `app_config.dart` 中设置正确的API地址
3. **完善页面**：各个Tab页面的具体实现
4. **完善功能**：搜索、消息中心、草稿箱等
5. **测试**：测试各个功能是否正常工作

