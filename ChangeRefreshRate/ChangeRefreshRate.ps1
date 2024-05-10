# 引入所需的类型定义和命名空间
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class DisplaySettings
{
    [DllImport("user32.dll")]
    public static extern int EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE devMode);

    [StructLayout(LayoutKind.Sequential)]
    public struct DEVMODE
    {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string dmDeviceName;  // 设备名称
        public short dmSpecVersion;  // 版本号
        public short dmDriverVersion;  // 驱动程序版本
        public short dmSize;  // 结构体大小
        public short dmDriverExtra;  // 驱动程序附加信息大小
        public int dmFields;  // 可变参数标志
        public int dmPositionX;  // X 坐标
        public int dmPositionY;  // Y 坐标
        public int dmDisplayOrientation;  // 显示方向
        public int dmDisplayFixedOutput;  // 固定输出
        public short dmColor;  // 颜色位数
        public short dmDuplex;  // 双工模式
        public short dmYResolution;  // Y 分辨率
        public short dmTTOption;  // TrueType 字体选项
        public short dmCollate;  // 复制选项
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string dmFormName;  // 纸张名称
        public short dmLogPixels;  // 逻辑像素
        public int dmBitsPerPel;  // 每个像素的位数
        public int dmPelsWidth;  // 每行像素数
        public int dmPelsHeight;  // 每列像素数
        public int dmDisplayFlags;  // 显示标志
        public int dmDisplayFrequency;  // 刷新率
    }

    public static int GetRefreshRate()
    {
        DEVMODE devMode = new DEVMODE();
        devMode.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));  // 设置结构体大小
        EnumDisplaySettings(null, -1, ref devMode);  // 获取当前显示设置
        return devMode.dmDisplayFrequency;  // 返回刷新率
    }
}
"@

$refreshRate = [DisplaySettings]::GetRefreshRate()  # 调用获取刷新率的方法
# Write-Host "当前显示器的刷新率为: $refreshRate Hz"  # 打印刷新率

if ($refreshRate -eq 60) {
    Start-Process -FilePath "qres.exe" -ArgumentList "/r:165" -NoNewWindow -Wait
    # Write-Host "刷新率已切换到: 165 Hz"
    $CurrentRefreshRate = 165
} elseif ($refreshRate -eq 165) {
    Start-Process -FilePath "qres.exe" -ArgumentList "/r:60" -NoNewWindow -Wait
    # Write-Host "刷新率已切换到: 60 Hz"
    $CurrentRefreshRate = 60
} else {
    Write-Host "未定义的刷新率，无法执行相应的命令。"
}

Add-Type -AssemblyName System.Windows.Forms 

$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$balloon.Icon = ".\refresh.ico" 
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info 
$balloon.BalloonTipTitle = '刷新率切换'
if ($CurrentRefreshRate -eq 60) {
    $balloon.BalloonTipText = '✅当前为: 60 Hz' 
} elseif ($CurrentRefreshRate -eq 165) {
    $balloon.BalloonTipText = '✅当前为: 165 Hz'
} else {
    $balloon.BalloonTipText = '❌切换失败'
}
$balloon.Visible = $true 
$balloon.ShowBalloonTip(3)
