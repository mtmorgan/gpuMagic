# codeMetaInfo=curMetaInfo
if (FALSE) {
    parserFunc = RProfile2_parserFunc
    checkFunc = RProfile2_checkFunc
    updateFunc = RProfile2_updateFunc
    codeMetaInfo = profileMeta1
    level = c("top")
}
parserFrame <- function(parserFunc, checkFunc, updateFunc, codeMetaInfo, 
    level = c("top")) {
    curCodeMetaInfo = codeMetaInfo
    parsedExp = codeMetaInfo$Exp
    code = c()
    for (i in seq(length(parsedExp))) {
        # if(i==3) stop()
        curExp = parsedExp[[i]]
        if (curExp == "{" && length(curExp) == 1) {
            next
        }
        if (!is.symbol(curExp) && !isNumeric(curExp)) {
            if (curExp[[1]] == "for") {
                loopIndExp = curExp[[3]]
                curLevel = c(level, "for")
                if (checkFunc(loopIndExp)) {
                  res = ProcessCodeSingle(parserFunc, updateFunc, curCodeMetaInfo, 
                    curLevel, parsedExp, code, i, loopIndExp)
                  curCodeMetaInfo = res$codeMetaInfo
                  parsedExp = res$parsedExp
                  code = res$code
                  loopIndExp = res$Exp
                }
                loopBodyExp = curExp[[4]]
                res = ProcessCodeChunk(parserFunc, checkFunc, updateFunc, 
                  curCodeMetaInfo, curLevel, parsedExp, code, i, loopBodyExp)
                curCodeMetaInfo = res$codeMetaInfo
                parsedExp = res$parsedExp
                code = res$code
                loopBodyExp = res$ExpChunk
                
                
                curExp[[3]] = loopIndExp
                curExp[[4]] = loopBodyExp
                code = c(code, curExp)
                next
            }
            
            
            if (curExp[[1]] == "if") {
                conditionExp = curExp[[2]]
                curLevel = c(level, "if")
                if (checkFunc(conditionExp)) {
                  res = ProcessCodeSingle(parserFunc, updateFunc, curCodeMetaInfo, 
                    curLevel, parsedExp, code, i, conditionExp)
                  curCodeMetaInfo = res$codeMetaInfo
                  parsedExp = res$parsedExp
                  code = res$code
                  conditionExp = res$Exp
                }
                for (k in 3:4) {
                  if (k > length(curExp)) 
                    next
                  conditionBodyExp = curExp[[k]]
                  res = ProcessCodeChunk(parserFunc, checkFunc, updateFunc, 
                    curCodeMetaInfo, curLevel, parsedExp, code, i, conditionBodyExp)
                  curCodeMetaInfo = res$codeMetaInfo
                  parsedExp = res$parsedExp
                  code = res$code
                  conditionBodyExp = res$ExpChunk
                  
                  curExp[[k]] = conditionBodyExp
                }
                
                curExp[[2]] = conditionExp
                code = c(code, curExp)
                next
            }
        }
        
        # I don't know who will use double bracket But I add it for making sure
        # it works
        if (length(curExp) > 1 && curExp[[1]] == "{") {
            warning("Unnecessary { has been found: ", deparse(curExp))
            curLevel = c(level, "{")
            res = ProcessCodeChunk(parserFunc, checkFunc, updateFunc, curCodeMetaInfo, 
                curLevel, parsedExp, code, i, curExp)
            curCodeMetaInfo = res$codeMetaInfo
            parsedExp = res$parsedExp
            code = res$code
            curExp = res$ExpChunk
            curExp[[1]] = NULL
            code = c(code, curExp)
            next
        }
        
        if (checkFunc(curExp)) {
            res = ProcessCodeSingle(parserFunc, updateFunc, curCodeMetaInfo, 
                level, parsedExp, code, i, curExp)
            curCodeMetaInfo = res$codeMetaInfo
            parsedExp = res$parsedExp
            code = c(res$code, res$Exp)
            next
        }
    }
    curCodeMetaInfo$Exp = code
    return(curCodeMetaInfo)
}
# inside the for and if loop
ProcessCodeChunk <- function(parserFunc, checkFunc, updateFunc, codeMetaInfo, 
    curLevel, parsedExp, code, i, ExpChunk) {
    curMetaInfo = codeMetaInfo
    # Add a curly bracket when the loop does not have it
    if (is.symbol(ExpChunk) || isNumeric(ExpChunk) || ExpChunk[[1]] != 
        "{") {
        ExpChunk = as.call(c(as.symbol("{"), ExpChunk))
    }
    ExpChunk = compressCodeChunk(ExpChunk)
    curMetaInfo$Exp = ExpChunk
    curMetaInfo$renameList = NULL
    res = parserFrame(parserFunc, checkFunc, updateFunc, curMetaInfo, curLevel)
    if ("renameList" %in% names(res)) {
        parsedExp = renamevariable(parsedExp, res$renameList, i)
        codeMetaInfo$renameList = rbind(codeMetaInfo$renameList, res$renameList)
    }
    res1 = updateFunc(type = "block", curLevel, codeMetaInfo, parsedExp, 
        code, i, res)
    if ("codeMetaInfo" %in% names(res1)) 
        codeMetaInfo = res1$codeMetaInfo
    if ("parsedExp" %in% names(res1)) 
        parsedExp = res1$parsedExp
    if ("code" %in% names(res1)) 
        code = res1$code
    ExpChunk = compressCodeChunk(res$Exp)
    list(codeMetaInfo = codeMetaInfo, parsedExp = parsedExp, code = code, 
        ExpChunk = ExpChunk)
}
# For a single line code parserFunc######## parserFunc should at least
# return a list with Exp as the element, the Exp is the current
# expression Optional return value: extCode: The expressions that will
# be added before the current expression renameList: renaming a
# variable, the framework is responsible to rename the variable in all
# the expressions next to the current one, the current one shoul be
# manually renamed. updateFunc######## updateFunc can be used to update
# anything in the codeMetaInfo, parsedExp or code Optional return
# value: codeMetaInfo: The description object to describe the property
# of code parsedExp: The expression that is parsing, usually not change
# code: The parsed expression
ProcessCodeSingle <- function(parserFunc, updateFunc, codeMetaInfo, curLevel, 
    parsedExp, code, i, Exp) {
    res = parserFunc(curLevel, codeMetaInfo, Exp)
    
    Exp = res$Exp
    code = c(code, res$extCode)
    res1 = updateFunc(type = "normal", curLevel, codeMetaInfo, parsedExp, 
        code, i, res)
    if ("codeMetaInfo" %in% names(res1)) 
        codeMetaInfo = res1$codeMetaInfo
    if ("parsedExp" %in% names(res1)) 
        parsedExp = res1$parsedExp
    if ("code" %in% names(res1)) 
        code = res1$code
    if ("renameList" %in% names(res)) {
        parsedExp = renamevariable(parsedExp, res$renameList, i)
        codeMetaInfo$renameList = rbind(codeMetaInfo$renameList, res$renameList)
    }
    list(codeMetaInfo = codeMetaInfo, parsedExp = parsedExp, code = code, 
        Exp = Exp)
}
renamevariable <- function(parsedExp, renameList, i) {
    for (j in seq_len(nrow(renameList))) parsedExp = renameVarInCode(parsedExp, 
        i, renameList[j, 1], renameList[j, 2])
    parsedExp
}
renameVarInCode <- function(code, start, oldName, newName) {
    oldName = as.character(oldName)
    newName = as.symbol(newName)
    if (start <= length(code)) {
        for (i in start:length(code)) {
            renameList = list(newName)
            names(renameList) = oldName
            code[[i]] = do.call("substitute", list(code[[i]], renameList))
        }
    }
    return(code)
}

general_updateFunc <- function(codeMetaInfo, parsedExp, code) {
    result = list()
    result$codeMetaInfo = codeMetaInfo
    result$parsedExp = parsedExp
    result$code = code
    result
}
