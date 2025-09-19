using Godot;

// 记住要引用System和System.Runtime.InteropServices这两个重要的命名空间
// System提供基础的系统功能，Runtime.InteropServices让我们能调用Windows系统的功能
using System;
using System.Runtime.InteropServices;

public partial class ApiManager : Node
{
	// 自动加载的管理类 - 这意味着游戏启动时会自动创建这个类的实例
	
	// GetActiveWindow() 函数用来获取当前活动窗口的句柄（可以理解为窗口的身份证号）
	// DllImport告诉程序：这个函数来自Windows系统的user32.dll文件，不是我们自己写的
	[DllImport("user32.dll")]
	public static extern IntPtr GetActiveWindow();

	// SetWindowLong() 函数用来修改窗口的特定属性
	// 参数说明：hWnd是窗口句柄，nIndex是要修改的属性索引，dwNewLong是新的属性值
	// 就像修改一个人的某个特征一样，我们需要知道是谁(句柄)，修改什么(索引)，改成什么(新值)
	[DllImport("user32.dll")]
	private static extern int SetWindowLong(IntPtr hWnd, int nIndex, uint dwNewLong);
	
	// 这是我们要修改的窗口属性的索引号，-20代表扩展样式属性
	// 就像学生档案里的第20项信息一样，每个数字代表不同的属性
	private const int GwlExStyle = -20;
	
	// 这些是窗口的特殊标志，用二进制的方式表示不同的功能
	private const uint WsExLayered = 0x00080000;			// 让窗口变成"分层窗口"，可以实现透明效果
	private const uint WsExTransparent = 0x00000020;		// 让窗口变成"点击穿透"，鼠标可以点击到下面的内容
	// 更多窗口样式可以查看：https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles 

	// 这个变量用来存储我们游戏窗口的句柄（身份证号）
	// IntPtr是一个特殊的数据类型，用来存储内存地址
	private IntPtr _hWnd;

	public override void _Ready()
	{
		// 储存窗口句柄 - 就像记住这个窗口的身份证号，以后要操作它就用这个号码
		_hWnd = GetActiveWindow();
		
		// 在程序启动时就把窗口设置为分层窗口，这是实现点击穿透的第一步
		// 就像给窗口贴上一个"我是特殊窗口"的标签
		SetWindowLong(_hWnd, GwlExStyle, WsExLayered );
	}
	
	// 这个函数用来设置窗口是否可以点击穿透，鼠标检测脚本会调用这个函数
	// clickthrough参数：true表示点击穿透，false表示正常点击
	public void SetClickThrough(bool clickthrough)
	{
		if (clickthrough)
		{
			// 当需要点击穿透时，我们设置两个标志：分层窗口 + 透明点击
			// 使用 | 符号把两个标志组合起来，就像同时贴上两个标签
			SetWindowLong(_hWnd, GwlExStyle,   WsExLayered | WsExTransparent);
		}
		else
		{
			// 当不需要点击穿透时，只设置分层窗口标志，这样窗口就能正常接收点击
			// 就像撕掉"透明点击"的标签，但保留"分层窗口"的标签
			SetWindowLong(_hWnd, GwlExStyle, WsExLayered);
		}
	}
	
	
	
	/* 什么是分层窗口？ 
	 * 在Windows系统中，分层窗口是一种特殊类型的窗口，它比普通窗口有更多优势：
	 * 
	 * 透明度功能：分层窗口可以部分透明，让下面窗口的内容显示出来。
	 * 这可以通过两种方式实现：
	 * 1. 颜色键控 - 设置某个特定颜色为透明（比如把所有绿色都变透明）
	 * 2. Alpha混合 - 为每个像素设置不同的透明度（就像调节每个点的透明程度）
	 *
	 * 复杂形状：分层窗口不一定要是方形的，可以做成任何形状。
	 * 通过定义自定义区域，可以创造更美观或更实用的窗口设计。
	 * （比如做成圆形窗口、星形窗口等）
	 *
	 * 流畅动画：分层窗口的动画效果更流畅，不会出现普通窗口那种闪烁或撕裂的问题。
	 * 这是因为系统会自动管理分层窗口与其他元素的合成过程，
	 * 就像专业的视频编辑软件一样平滑地混合不同层级的内容。
	 */
}
