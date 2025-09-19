using Godot;

public partial class MouseDetection : Node
{
	
	// 自动加载的鼠标检测类 - 负责检测鼠标下面是否有可见内容
	
	private ApiManager _api;

	public override void _Ready()
	{
		// 获取API管理器的引用，这样我们就能控制窗口的点击穿透属性
		_api = GetNode<ApiManager>("/root/ApiManager");
		
		// 程序启动时默认设置为点击穿透模式
		// 这意味着一开始鼠标点击会穿过窗口，直到检测到有内容的地方
		_api.SetClickThrough(true);
	}
	
	// 使用物理处理函数来检测像素比较好，因为它在渲染完成后执行
	// 这样确保我们检测的是最新渲染的画面内容
	// 如果担心性能，也可以每隔几帧才检测一次（比如每3帧检测一次）
	public override void _PhysicsProcess(double delta)
	{
		DetectPassthrough();
	}

	
	// 检测鼠标光标下方像素的颜色，基于视口纹理进行分析
	// 如果在复杂场景中每帧都执行这个检测，可能会影响性能
	// 我们用这个方法来判断窗口是否应该可以点击
	// 你也可以选择其他检测方法！比如检测3D物体的碰撞等
	private void DetectPassthrough()
	{
		// 获取当前的视口（可以理解为游戏画面的显示区域）
		Viewport viewport = GetViewport();
		
		// 获取视口的纹理图像 - 就是把当前显示的内容转换成一张图片
		Image img = viewport.GetTexture().GetImage();
		if (img == null) return;
		
		// 获取视口的可见矩形区域
		Rect2 rect = viewport.GetVisibleRect();
		
		// 获取鼠标在视口中的位置坐标
		Vector2 mousePosition = viewport.GetMousePosition();
		
		// 确保鼠标位置在视口范围内
		if (mousePosition.X < 0 || mousePosition.Y < 0 || 
			mousePosition.X >= rect.Size.X || mousePosition.Y >= rect.Size.Y)
		{
			img.Dispose();
			return;
		}
		
		int viewX = (int)mousePosition.X;
		int viewY = (int)mousePosition.Y;

		// 计算鼠标位置在图像中的对应坐标（图像的尺寸等于窗口尺寸）
		// 这里做了一个比例换算，因为视口坐标和图像坐标可能不同
		int x = (int)(img.GetSize().X * viewX / rect.Size.X);
		int y = (int)(img.GetSize().Y * viewY / rect.Size.Y);

		// 确保坐标在图像范围内，然后获取该位置的像素颜色
		if (x >= 0 && y >= 0 && x < img.GetSize().X && y < img.GetSize().Y)
		{
			Color pixel = img.GetPixel(x, y);
			// 检查像素的透明度：如果Alpha值大于0.5，说明这里有可见内容
			// Alpha值0表示完全透明，1表示完全不透明，0.5是中间值
			SetClickability(pixel.A > 0.5f); 
		}

		// 非常重要！必须释放图像内存，否则会造内存泄漏！！！！！
		// 就像用完纸巾要扔掉一样，用完图像也要清理掉
		img.Dispose();
	}
	
	// 为了提高性能，不在每帧都调用API，而是检查状态是否改变了才调用
	// 这样可以避免重复设置相同的窗口属性，减少不必要的系统调用
	private bool _clickthrough = true;
	private void SetClickability(bool clickable)
	{
		// 只有当点击状态真的改变了，我们才需要更新窗口属性
		if (clickable != _clickthrough)
		{
			// 更新当前状态记录
			_clickthrough = clickable;
			// 注意：clickthrough的含义和clickable是相反的
			// clickable=true 表示可以点击，所以 clickthrough=false
			// clickable=false 表示不可点击（穿透），所以 clickthrough=true
			_api.SetClickThrough(!clickable);
		}
	}
}
