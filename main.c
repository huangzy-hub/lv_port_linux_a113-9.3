#include "lvgl/lvgl.h"
// v9 驱动头文件路径（内置到 lvgl/src/drivers）
#include "lvgl/src/drivers/display/fb/lv_linux_fbdev.h"
#include "lvgl/src/drivers/evdev/lv_evdev.h"
#include <unistd.h>
#include <sys/time.h>

/* ===================== 1. 硬件参数配置（根据开发板修改） ===================== */
#define DISP_HOR_RES    1024    // 屏幕水平分辨率
#define DISP_VER_RES    600     // 屏幕垂直分辨率
#define DISP_BUF_SIZE   (DISP_HOR_RES * DISP_VER_RES * 4)  // 全屏单缓冲（4字节/像素）
#define TOUCH_DEV_PATH  "/dev/input/event5"  // 触摸屏设备路径
#define FB_DEV_PATH     "/dev/fb0"           // 帧缓冲设备路径

/* ===================== 2. 自定义 Tick 函数（可选，推荐） ===================== */
uint32_t custom_tick_get(void) {
    static uint64_t start_ms = 0;
    if(start_ms == 0) {
        struct timeval tv;
        gettimeofday(&tv, NULL);
        start_ms = (tv.tv_sec * 1000000 + tv.tv_usec) / 1000;
    }
    struct timeval tv;
    gettimeofday(&tv, NULL);
    uint64_t now_ms = (tv.tv_sec * 1000000 + tv.tv_usec) / 1000;
    return now_ms - start_ms;
}

/* ===================== 3. 屏幕+触摸初始化核心函数 ===================== */
void lv_hw_init(void) {
    // 1. LVGL 核心初始化（必须第一步）
    lv_init();

    // 2. 绑定自定义 Tick 函数（高精度时间基准，推荐）
    lv_tick_set_cb(custom_tick_get);

    // 3. 屏幕显示配置（v9 对象化 API）
    // 3.1 创建 FBDEV 显示对象
    lv_display_t *disp = lv_linux_fbdev_create();
    // 3.2 绑定帧缓冲设备文件
    lv_linux_fbdev_set_file(disp, FB_DEV_PATH);
    // 3.3 设置屏幕分辨率
    lv_display_set_resolution(disp, DISP_HOR_RES, DISP_VER_RES);
    // 3.4 配置显示缓冲（可选：单缓冲/双缓冲/行缓冲）
    static lv_color_t disp_buf[DISP_BUF_SIZE];  // 单缓冲
    // static lv_color_t disp_buf1[DISP_BUF_SIZE], disp_buf2[DISP_BUF_SIZE]; // 双缓冲
    lv_display_set_buffers(
        disp,
        disp_buf,    // 缓冲1
        NULL,        // 缓冲2（NULL=单缓冲，填disp_buf2=双缓冲）
        DISP_BUF_SIZE,
        LV_DISPLAY_RENDER_MODE_PARTIAL  // 局部刷新（更流畅）
    );

    // 4. 触摸屏配置（v9 对象化 API）
    // 4.1 创建 evdev 输入对象
    //lv_indev_t *indev = lv_evdev_create();

    lv_indev_t *indev = lv_evdev_create(LV_INDEV_TYPE_POINTER, TOUCH_DEV_PATH);

    // 4.2 绑定触摸屏设备文件
    //lv_evdev_set_file(indev, TOUCH_DEV_PATH);
    // 4.3 设置输入类型为指针（触摸屏/鼠标通用）
    //lv_indev_set_type(indev, LV_INDEV_TYPE_POINTER);
}

/* ===================== 4. main 函数入口 ===================== */
int main(void) {
    // 第一步：初始化屏幕+触摸硬件
    lv_hw_init();

    // 第二步：加载自定义 UI/业务逻辑（替换为你的代码）
    lv_demo_widgets();  // 官方示例
    // your_ui_init();     // 自定义 UI 初始化

    // 第三步：LVGL 主循环（必须）
    while(1) {
        lv_timer_handler();  // 处理 LVGL 定时器/动画/刷新
        usleep(5000);        // 5ms 延时，平衡 CPU 占用
    }

    return 0;
}