如果依赖项是一个对象中的属性，应该直接使用对象的属性而不是对象本身

在 useEffect 中使用 setState(newState) 并依赖 state，内部执行会进入死循环。应该使用 setState(pre => newState) 来更新

应该使用更新函数而不是状态变量本身



在开发环境中，通常会使用热更新的模式进行开发，保证每次代码变动后，页面会及时更新

这就可能导致 useEffect 中的一些副作用（例如计时器）会被重复执行，所以清理函数是必要的

清理函数会在组件 rerender 前被调用一次

严格模式下，组件会被渲染两次，其目的就在于保证热更新后 useEffect 的清理函数能够运行，从而解决上述的问题



API Request

大家都知道，组件的数据请求一般会在组件正确挂载后执行

```react
useEffect(() => {
    fetch('')
        .then((res) => res.json())
        .then((data) => {
            setPosts(data)
        })
}, [])
```

但当在请求过程中，切换组件、组件卸载或者组件重新渲染后，这个请求仍然发出了且拿到了响应，并更新了 state

对于具有更多状态的更复杂的情况，这种现象可能会引发更多问题

更合理的行为是一旦离开组件或者卸载组件后，请求应该被立刻取消

可以使用 useEffect 的清理函数来解决这个问题

```js
useEffect(() => {
    const controller = new AbortConcroller()
    const signal = controller.signal
    
    fetch('', { signal })
        .then((res) => res.json())
        .then((data) => {
            setPosts(data)
        }).catch((err) => {
        	if(err.name === 'AbortError') {
                console.log('request cancelled')
            }
    	})
    
    return () => {
    	controller.abort()
    }
}, [])

useEffect(() => {
    const cancelToken = axios.cancelToken.source()
    
    axios.get('', { cancelToken: cancelToken.token })
        .then((data) => {
            setPosts(data)
        }).catch((err) => {
        	if(axios.isCancel(err)) {
                console.log('request cancelled')
            }
    	})
    
    return () => {
    	cancelToken.cancel()
    }
}, [])
```

当然，为了更好的开发体验，强烈建议使用 useRequest 或者 useSWR 库来做数据请求与缓存管理