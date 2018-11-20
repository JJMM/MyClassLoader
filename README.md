# MyClassLoader
1、+load方法替代工具（解决+load滥用导致启动时间超长问题）。<br>
2、Swift pod工程类似+load方法的调用方式（Swift没有+load，难以实现注册模式）

Objective-C的+Load方法设计的天然缺陷和开发者的滥用，导致系统启动时间大大增加，原来请参考pre-main过程<br>
Swift语言抛弃+Load，连苹果自身都认为+Load方法不应该存在，其他现代语言基本也没有+Load这种特性<br>
结论：+Load不应该使用<br>
不用+Load解决方案：目前pod库组件化解耦基本都是在+Load里注册，统一调用，MyClassLoader提供类似+Load的调用能力，调用时机由开发者控制，建议在开屏广告、介绍引导页面调用<br>

## How To Get Started

#### Podfile

```
pod "MyClassLoader"
```

## License

MyClassLoader is licensed under the terms of the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html). Please see the [LICENSE](LICENSE) file for full details.

## Contributions

Contributions are totally welcome. We'll review all pull requests and if you send us a good one/are interested we're happy to give you push access to the repo. Or, you know, you could just come work with us.<br>

Please pay attention to add Star, your support is my greatest motivation, thank you.
