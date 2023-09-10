object "Simple" {
    code {
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))        
    }

    object "runtime" {
        
        // runtime only return 42
        code {
            mstore(0x00, 0x2a)
            return(0x00, 0x20)
        }
    }
}


// 600a600d600039600a6000f3fe602a60005260206000f3
// /<------init code------->/<---runtime code-->/