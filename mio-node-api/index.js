const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
    res.json([{
        name: 'Edoardo',
        email: 'editestar@gmail.com'
    },{
        name: 'Pippo',
        email: 'pippo@gmail.com'
    }])
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})