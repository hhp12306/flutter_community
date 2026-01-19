import { FlutterAbility, FlutterEngine, MethodChannel, EventChannel } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '@ohos/flutter_module';
import { FlutterBridgeHandler } from '../utils/FlutterBridgeHandler';

/**
 * 主Ability
 * 负责初始化Flutter Engine并设置MethodChannel和EventChannel
 */
export default class EntryAbility extends FlutterAbility {
  private methodChannel?: MethodChannel;
  private eventChannel?: EventChannel;
  private bridgeHandler?: FlutterBridgeHandler;

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    // 创建Bridge处理器
    this.bridgeHandler = new FlutterBridgeHandler(this.context);

    // 设置MethodChannel
    this.setupMethodChannel(flutterEngine);

    // 设置EventChannel
    this.setupEventChannel(flutterEngine);
  }

  /**
   * 设置MethodChannel
   * 注意：根据flutter_ohos库的实际API，可能需要调整以下代码
   */
  private setupMethodChannel(flutterEngine: FlutterEngine) {
    try {
      // 方式1：如果flutter_ohos提供了getBinaryMessenger方法
      const binaryMessenger = flutterEngine.getDartExecutor().getBinaryMessenger();
      this.methodChannel = new MethodChannel(binaryMessenger, 'com.example.my_flutter_module2/native');
    } catch (error) {
      // 方式2：如果API不同，可能需要使用其他方式获取binaryMessenger
      // 例如：flutterEngine.getBinaryMessenger() 或 flutterEngine.binaryMessenger
      console.error('创建MethodChannel失败，尝试备用方式:', error);
      // TODO: 根据实际API调整
    }

    if (this.methodChannel) {
      // 设置方法调用处理器
      // 注意：根据flutter_ohos的实际API，MethodCallHandler可能期望不同的签名
      // 定义MethodCall接口
      interface MethodCall {
        method: string;
        arguments?: Record<string, Object>;
      }
      // 创建handler函数
      const handler = async (call: MethodCall): Promise<Object | null> => {
        try {
          if (this.bridgeHandler) {
            const method = call.method;
            const args = call.arguments || {};
            const result = await this.bridgeHandler.handleMethodCall(method, args);
            return result;
          } else {
            const error: Error = new Error('BridgeHandler未初始化');
            throw error;
          }
        } catch (error) {
          console.error('处理MethodCall失败:', error);
          const err: Error = error instanceof Error ? error : new Error(String(error));
          throw err;
        }
      };
      // 使用类型断言来适配MethodCallHandler
      // 先转换为unknown，再转换为目标类型，避免类型不兼容问题
      // (this.methodChannel as unknown as {
      //   setMethodCallHandler(handler: (call: MethodCall) => Promise<Object | null>): void;
      // }).setMethodCallHandler(handler);
    } else {
      console.error('MethodChannel创建失败，请检查flutter_ohos库的API');
    }
  }

  /**
   * 设置EventChannel
   * 注意：根据flutter_ohos库的实际API，可能需要调整以下代码
   */
  private setupEventChannel(flutterEngine: FlutterEngine) {
    try {
      // 方式1：如果flutter_ohos提供了getBinaryMessenger方法
      const binaryMessenger = flutterEngine.getDartExecutor().getBinaryMessenger();
      this.eventChannel = new EventChannel(binaryMessenger, 'com.example.my_flutter_module2/native_events');
    } catch (error) {
      // 方式2：如果API不同，可能需要使用其他方式
      console.error('创建EventChannel失败，尝试备用方式:', error);
      // TODO: 根据实际API调整
    }

    if (this.eventChannel) {
      // 设置事件流处理器（可选，用于原生向Flutter发送事件）
      // 例如：登录状态变化、用户信息更新等
      // this.eventChannel.setStreamHandler(...);
      console.info('EventChannel已创建，可以设置StreamHandler');
    } else {
      console.error('EventChannel创建失败，请检查flutter_ohos库的API');
    }
  }

  onDestroy() {
    // 清理资源
    this.methodChannel = undefined;
    this.eventChannel = undefined;
    this.bridgeHandler = undefined;
    super.onDestroy();
  }
}
