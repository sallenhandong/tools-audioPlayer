//
//  ViewController.m
//  audioPlayerDemo
//
//  Created by jefactoria on 2017/4/17.
//  Copyright © 2017年 sallen. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

// 屏幕高度
#define SCREEN_HEIGHT         [[UIScreen mainScreen] bounds].size.height
// 屏幕宽度
#define SCREEN_WIDTH          [[UIScreen mainScreen] bounds].size.width

@interface ViewController ()<AVAudioRecorderDelegate>{
    
    AVAudioRecorder *recorder;
    NSTimer *timer;
    NSURL *urlPlay;
    UISlider *processSlider;
    UILabel *currentPlayLabel;
    
}
@property (retain, nonatomic) AVAudioPlayer *avPlay;
@property(nonatomic,strong)NSTimer *avtimer;//监控音频播放进度
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addChildView];
    [self setupAudio];
}
-(void)addChildView{

    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordButton.frame = CGRectMake(SCREEN_WIDTH/2 - 40, 400, 80, 80);
    [recordButton setBackgroundImage:[UIImage imageNamed:@"luyinzhengchang"] forState:UIControlStateNormal];
    [recordButton setBackgroundImage:[UIImage imageNamed:@"luyinanxia"] forState:UIControlStateHighlighted];
    [recordButton addTarget:self action:@selector(btnDown) forControlEvents:UIControlEventTouchDown];
    [recordButton addTarget:self action:@selector(btnUp) forControlEvents:UIControlEventTouchUpInside];
    [recordButton addTarget:self action:@selector(btnDragUp) forControlEvents:UIControlEventTouchDragExit];
    [self.view addSubview:recordButton];
    
    UIButton *playButtion = [UIButton buttonWithType:UIButtonTypeCustom];
    playButtion.frame = CGRectMake(SCREEN_WIDTH/2 - 40, 250, 80, 80);
    [playButtion setTitle:@"播放" forState:UIControlStateNormal];
    playButtion.titleLabel.textColor = [UIColor whiteColor];
    [playButtion setBackgroundColor:[UIColor redColor]];
    [playButtion addTarget:self action:@selector(playRecod) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButtion];
    
    
    processSlider = [[UISlider alloc] initWithFrame:CGRectMake(90, 220, 200, 20)];
    processSlider.thumbTintColor = [UIColor clearColor];
    processSlider.minimumTrackTintColor = [UIColor redColor];
    
    [processSlider addTarget:self action:@selector(processChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:processSlider];
    
    [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(updateSliderValue) userInfo:nil repeats:YES];
    
    
    currentPlayLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 200, 150, 30)];
    currentPlayLabel.text = @"00:00";
    currentPlayLabel.textColor = [UIColor redColor];
    [self.view addSubview:currentPlayLabel];
    
    
    [self playProgress];

}
-(void)setupAudio{

    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/lll.aac", strUrl]];
    urlPlay = url;
    
    NSError *error;
    //初始化
    recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    //开启音量检测
    recorder.meteringEnabled = YES;
    recorder.delegate = self;



}

- (void)playProgress{
    
    int time = (int)self.avPlay.currentTime;
    
    int minutes = self.avPlay.duration / 60;
    
    int seconds = (int)self.avPlay.duration % 60;
    
    int currentMinutes = time / 60;
    
    int currentSeconds = time % 60;
    
    NSString *min = [NSString stringWithFormat:@"%d",minutes];
    NSString *sec = [NSString stringWithFormat:@"%d",seconds];
    NSString *currentMin = [NSString stringWithFormat:@"%d",currentMinutes];
    NSString *currentSec = [NSString stringWithFormat:@"%d",currentSeconds];
    if (minutes < 10) {
        
        min = [NSString stringWithFormat:@"0%d",minutes];
        
    }
    if (seconds < 10) {
        
        sec = [NSString stringWithFormat:@"0%d",seconds];
        
    }
    if (currentMinutes < 10) {
        
        currentMin = [NSString stringWithFormat:@"0%d",currentMinutes];
        
    }
    if (currentSeconds < 10) {
        
        currentSec = [NSString stringWithFormat:@"0%d",currentSeconds];
        
    }
    currentPlayLabel.text = [NSString stringWithFormat:@"%@:%@/%@:%@",currentMin,currentSec,min,sec];
}
-(void)startTimer{
    
    self.avtimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playProgress) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.avtimer forMode:NSRunLoopCommonModes];
    
}
-(void)playRecod{
    
    if (self.avPlay.playing) {
        [self.avPlay stop];
        return;
    }
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:urlPlay error:nil];
    self.avPlay = player;
    [self.avPlay play];
    
    if (self.avPlay.duration != 0) {
        [self startTimer];
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGRect t = processSlider.bounds;
    
    float v = [processSlider minimumValue] + ([[touches anyObject] locationInView: self.view].x - t.origin.x - 4.0) * (([processSlider maximumValue]-[processSlider minimumValue]) / (t.size.width - 8.0));
    [processSlider setValue: v];
    [super touchesBegan: touches withEvent: event];
    
}
-(void)processChanged
{
    [self.avPlay setCurrentTime:processSlider.value * self.avPlay.duration];
}

-(void)updateSliderValue
{
    processSlider.value = self.avPlay.currentTime/self.avPlay.duration;
}
- (void)btnDown
{
    //创建录音文件，准备录音
    if ([recorder prepareToRecord]) {
        //开始
        [recorder record];
    }
    
    //设置定时检测
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
}
- (void)btnUp
{
    double cTime = recorder.currentTime;
    if (cTime > 2) {//如果录制时间<2 不发送
        NSLog(@"发出去");
    }else {
        //删除记录的文件
        [recorder deleteRecording];
        //删除存储的
    }
    [recorder stop];
    [timer invalidate];
}
- (void)btnDragUp
{
    //删除录制文件
    [recorder deleteRecording];
    [recorder stop];
    [timer invalidate];
    
    NSLog(@"取消发送");
}
- (void)detectionVoice
{
    [recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    NSLog(@"%lf",lowPassResults);
    
}

-(void)dealloc{

    [self.avtimer invalidate];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
