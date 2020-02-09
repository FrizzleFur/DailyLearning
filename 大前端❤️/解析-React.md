# 解析-React


## Component



## Redux

将模型的更新逻辑全部集中于一个特定的层（Flux 里的 store，Redux 里的 reducer），Redux不允许程序直接修改数据，而是用一个叫作 “action” 的普通对象来对更改进行描述。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200127222042.png)

```js
(state, action) => state
```

action：是事件，它本质上是JavaScript的普通对象，它描述的是“发生了什么”。action由type：string和其他构成。
reducer是一个监听器，只有它可以改变状态。是一个纯函数，它不能修改state,所以必须是生成一个新的state。在default情况下，必须但会旧的state。
store是一个类似数据库的存储（或者可以叫做状态树），需要设计自己的数据结构来在状态树中存储自己的数据。


Action
Action 是把数据从应用传到store的有效载荷，它是store数据的唯一来源，一般来说，我们通过store.dispatch()将action传到store。

Action创建函数
Action 创建函数 就是生成 action 的方法。“action” 和 “action 创建函数” 这两个概念很容易混在一起，使用时最好注意区分。

Redux中action创建函数只是简单返回一个action。

改变userName的示例：


export function changeUserName(userName) {  // action创建函数
    return {                             // 返回一个action
        type: 'CHANGE_USERNAME',
        payload: userName,
    };
}





-------


React

一些小型项目，只使用 React 完全够用了，数据管理使用props、state即可，那什么时候需要引入Redux呢？ 当渲染一个组件的数据是通过props从父组件中获取时，通常情况下是 A --> B，但随着业务复杂度的增加，有可能是这样的：A --> B --> C --> D --> E，E需要的数据需要从A那里通过props传递过来，以及对应的 E --> A逆向传递callback。组件BCD是不需要这些数据的，但是又必须经由它们来传递，这确实有点不爽，而且传递的props以及callback对BCD组件的复用也会造成影响。或者兄弟组件之间想要共享某些数据，也不是很方便传递、获取等。诸如此类的情况，就有必要引入Redux了。

其实 A --> B --> C --> D --> E 这种情况，React不使用props层层传递也是能拿到数据的，使用Context即可。后面要讲到的react-redux就是通过Context让各个子组件拿到store中的数据的。

Redux

其实我们只是想找个地方存放一些共享数据而已，大家都可以获取到，也都可以进行修改，仅此而已。 那放在一个全部变量里面行不行？行，当然行，但是太不优雅，也不安全，因为是全局变量嘛，谁都能访问、谁都能修改，有可能一不小心被哪个小伙伴覆盖了也说不定。那全局变量不行就用私有变量呗，私有变量、不能轻易被修改，是不是立马就想到闭包了...

现在要写这样一个函数，其满足：

存放一个数据对象
外界能访问到这个数据
外界也能修改这个数据
当数据有变化的时候，通知订阅者


function createStore(reducer, initialState) {
 // currentState就是那个数据
 let currentState = initialState;
 let listener = () => {};
 
 function getState() {
 return currentState;
 }
 function dispatch(action) {
 currentState = reducer(currentState, action); // 更新数据
 listener(); // 执行订阅函数
 return action;
 }
 function subscribe(newListener) {
 listener = newListener;
 // 取消订阅函数
 return function unsubscribe() {
  listener = () => {};
 };
 }
 return {
 getState,
 dispatch,
 subscribe
 };
}
 
const store = createStore(reducer);
store.getState(); // 获取数据
store.dispatch({type: 'ADD_TODO'}); // 更新数据
store.subscribe(() => {/* update UI */}); // 注册订阅函数
更新数据执行的步骤：

What：想干什么 --- dispatch(action)
How：怎么干，干的结果 --- reducer(oldState, action) => newState
Then?：重新执行订阅函数（比如重新渲染UI等）
这样就实现了一个store，提供一个数据存储中心，可以供外部访问、修改等，这就是Redux的主要思想。 所以，Redux确实和React没有什么本质关系，Redux可以结合其他库正常使用。只不过Redux这种数据管理方式，跟React的数据驱动视图理念很合拍，它俩结合在一起，开发非常便利。

现在既然有了一个安全的地方存取数据，怎么结合到React里面呢？ 我们可以在应用初始化的时候，创建一个window.store = createStore(reducer)，然后在需要的地方通过store.getState()去获取数据，通过store.dispatch去更新数据，通过store.subscribe去订阅数据变化然后进行setState...如果很多地方都这样做一遍，实在是不堪其重，而且，还是没有避免掉全局变量的不优雅。

React-Redux

由于全局变量有诸多的缺点，那就换个思路，把store直接集成到React应用的顶层props里面，只要各个子组件能访问到顶层props就行了，比如这样：


<TopWrapComponent store={store}>
 <App />
</TopWrapComponent>,
React恰好提供了这么一个钩子，Context，用法很简单，看一下官方demo就明了。现在各个子组件已经能够轻易地访问到store了，接下来就是子组件把store中用到的数据取出来、修改、以及订阅更新UI等。每个子组件都需要这样做一遍，显然，肯定有更便利的方法：高阶组件。通过高阶组件把store.getState()、store.dispatch、store.subscribe封装起来，子组件对store就无感知了，子组件正常使用props获取数据以及正常使用callback触发回调，相当于没有store存在一样。

下面是这个高阶组件的大致实现：

function connect(mapStateToProps, mapDispatchToProps) {
 return function(WrappedComponent) {
 class Connect extends React.Component {
  componentDidMount() {
  // 组件加载完成后订阅store变化，如果store有变化则更新UI
  this.unsubscribe = this.context.store.subscribe(this.handleStoreChange.bind(this));
  }
  componentWillUnmount() {
  // 组件销毁后，取消订阅事件
  this.unsubscribe();
  }
  handleStoreChange() {
  // 更新UI
  this.forceUpdate();
  }
  render() {
  return (
   <WrappedComponent
   {...this.props}
   {...mapStateToProps(this.context.store.getState())} // 参数是store里面的数据
   {...mapDispatchToProps(this.context.store.dispatch)} // 参数是store.dispatch
   />
  );
  }
 }
 Connect.contextTypes = {
  store: PropTypes.object
 };
 return Connect;
 };
}
使用connect的时候，我们知道要写一些样板化的代码，比如mapStateToProps、mapDispatchToProps这两个函数：


const mapStateToProps = state => {
 return {
 count: state.count
 };
};
 
const mapDispatchToProps = dispatch => {
 return {
 dispatch
 };
};
 
export default connect(mapStateToProps, mapDispatchToProps)(Child);
 
// 上述代码执行之后，可以看到connect函数里面的
 <WrappedComponent
 {...this.props}
 {...mapStateToProps(this.context.store.getState())}
 {...mapDispatchToProps(this.context.store.dispatch)}
 />
 
// 就变成了
 <WrappedComponent
 {...this.props}
 {count: store.getState().count}
 {dispatch: store.dispatch}
 />
// 这样，子组件Child的props里面就多了count和dispatch两个属性

// count可以用来渲染UI，dispatch可以用来触发回调

So，这样就OK了？OK了。 通过一个闭包生成一个数据中心store，然后把这个store绑定到React的顶层props里面，子组件通过HOC建立与顶层props.store的联系，进而获取数据、修改数据、更新UI。 这里主要讲了一下三者怎么窜在一起的，如果想了解更高级的功能，比如redux中间件、reducer拆分、connect的其他参数等，可以去看一下对应的源码。


# 参考

1. [详解react、redux、react-redux之间的关系](https://www.jianshu.com/p/728a1afce96d)
2. [React中的Redux](https://www.jianshu.com/p/2c728a70078e)