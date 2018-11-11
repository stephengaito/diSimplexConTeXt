-- A Lua file

-- from file: preamble.tex after line: 50

-- This is the lua code associated with t-diSimp.mkiv

if not modules then modules = { } end modules ['t-diSimp'] = {
    version   = 1.000,
    comment   = "ConTeXt macros for diSimplex papers -- lua",
    author    = "PerceptiSys Ltd (Stephen Gaito)",
    copyright = "PerceptiSys Ltd (Stephen Gaito)",
    license   = "MIT License"
}

thirddata        = thirddata        or {}
thirddata.diSimp = thirddata.diSimp or {}

local diSimp   = thirddata.diSimp

local tInsert = table.insert
local tConcat = table.concat
local tRemove = table.remove
local tSort   = table.sort
local sFmt    = string.format
local sMatch  = string.match
local toStr   = tostring

interfaces.writestatus('diSimp', "loaded diSimp macros")

-- from file: documentSetup.tex after line: 350

local insideComponent = {}
insideComponent['component']   = 0
insideComponent['environment'] = 0
insideComponent['product']     = 0
insideComponent['project']     = 0

local diSimpPaths   = {}
local pathSeparator = package.config:sub(1, 1)

local function lastDiSimpPath()
  return diSimpPaths[#diSimpPaths] or ""
end

diSimp.lastDiSimpPath = lastDiSimpPath

local function pushDiSimpPath(aFullPath)
  texio.write_nl('pushDiSimpPath('..aFullPath..')')
  local aFullPathDir =
    aFullPath:gsub('[^'..pathSeparator..']+$', '')
  texio.write_nl('  aFullPathDir: ['..aFullPathDir..']')
  if aFullPathDir:sub(-1) ~= '/' then
    aFullPathDir = aFullPathDir..pathSeparator
  end
  tInsert(diSimpPaths, aFullPathDir)
  for i, aPath in ipairs(diSimpPaths) do
    texio.write_nl('diSimpPaths['..toStr(i)..']: ['..aPath..']')
  end
end

-- repeat after me... this WILL break!!!
--
-- the use of environments.arguments.fulljobname
-- was infered from grep'ing the experimental distribution
-- for fulljobname and finding it defined in the
-- the environment table.
-- (defined in core-sys.lua)
--
pushDiSimpPath(file.collapsepath(environment.arguments.fulljobname,true))

local function popDiSimpPath()
  texio.write_nl('popDiSimpPath()')
  tRemove(diSimpPaths)
  for i, aPath in ipairs(diSimpPaths) do
    texio.write_nl('diSimpPaths['..toStr(i)..']: ['..aPath..']')
  end
  texio.write_nl('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
end

diSimp.popDiSimpPath = popDiSimpPath

local function findDiSimpPath(curBasePath, componentPath, origBasePath)
  texio.write_nl('findDiSimpPath(['..curBasePath..'],['..componentPath..'],['..origBasePath..'])')
  local potentialPath =
    file.collapsepath(curBasePath..componentPath, true)
  if lfs.attributes(potentialPath..'.tex', 'mode') == 'file' then
    texio.write_nl('found: ['..potentialPath..']')
    return potentialPath
  end
  potentialPath =
    file.collapsepath(curBasePath..'doc/'..componentPath, true)
  if lfs.attributes(potentialPath..'.tex', 'mode') == 'file' then
    texio.write_nl('found: ['..potentialPath..']')
    return potentialPath
  end
  if curBasePath == '' or curBasePath == pathSeparator then
    texio.write_nl('no path found using: ['..origBasePath..componentPath..']')
    return file.collapsepath(origBasePath..componentPath, true)
  end
  local newCurBasePath =
    curBasePath:gsub('[^'..pathSeparator..']+'..pathSeparator..'$','')
  return findDiSimpPath(newCurBasePath, componentPath, origBasePath)
end

local function diSimpComponent(componentType, componentPath)
  texio.write_nl('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
  texio.write_nl('diSimpComponent(['..componentType..'],['..componentPath..'])')
  if componentType == 'environment' and 1 < insideComponent['component'] then
    -- do nothing
  else
    -- we are either NOT an environment
    -- OR we are an environment but inside the first start/stop component pair
    local basePath = lastDiSimpPath()
    local thisComponentPath = findDiSimpPath(basePath, componentPath, basePath)
    texio.write_nl(' thisComponentPath: ['..thisComponentPath..']')
    pushDiSimpPath(thisComponentPath)
    tex.print({
      '\\'..componentType..' '..thisComponentPath,
      '\\popDiSimpPath'
    })
  end
end

diSimp.diSimpComponent = diSimpComponent

local function startDiSimpComponent(componentType, componentName)
  texio.write_nl('startDiSimpComponent(['..componentType..'],['..componentName..']')
  for k,v in pairs(insideComponent) do
    texio.write_nl('insideComponent['..k..'] = '..toStr(v))
  end
  if insideComponent[componentType] < 1 then
    tex.print('\\start'..componentType..' '..componentName..'\\relax')
  end
  insideComponent[componentType] = insideComponent[componentType] + 1
  texio.write_nl(
    '\\startDiSimpComponent('..componentType..')'..
    '['..toStr(insideComponent[componentType])..']'
  )
end

diSimp.startDiSimpComponent = startDiSimpComponent

local function stopDiSimpComponent(componentType)
  texio.write_nl('stopDiSimpComponent(['..componentType..']')
  texio.write_nl(
    '\\stopDiSimpComponent('..componentType..')'..
    '['..toStr(insideComponent[componentType])..']'
  )
  insideComponent[componentType] = insideComponent[componentType] - 1
  for k,v in pairs(insideComponent) do
    texio.write_nl('insideComponent['..k..'] = '..toStr(v))
  end
  if insideComponent[componentType] < 1 then
    if insideComponent[componentType] < 0 then
      texio.write_nl('ERRROR: unbalanced number of \\stop'..componentType)
    end
    texio.write_nl('CALLING \\stop'..componentType)
    tex.print('\\stop'..componentType..'\\relax')
  end
end

diSimp.stopDiSimpComponent = stopDiSimpComponent

-- from file: documentSetup.tex after line: 600

-- repeat after me... this WILL break!!!
--
local function startAppendices(sectionDepth)
  local numbers = structures.documents.data.numbers
  for i=sectionDepth,#numbers,1 do
    numbers[i] = 0
  end
end

diSimp.startAppendices = startAppendices