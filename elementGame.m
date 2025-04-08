function elementGame()
    % 元素合成遊戲
    
    % 顯示難度選擇視窗
    difficultyFig = figure('Name', '元素合成遊戲 - 難度選擇', ...
        'Position', [300, 300, 350, 250], ...
        'Color', [0.9 0.9 0.9], 'MenuBar', 'none', 'NumberTitle', 'off');
    
    % 難度選擇標題
    uicontrol('Parent', difficultyFig, 'Style', 'text', ...
        'Position', [75, 200, 200, 30], ...
        'String', '選擇遊戲難度', 'FontSize', 16, 'FontWeight', 'bold');
    
    % 簡單模式按鈕
    uicontrol('Parent', difficultyFig, 'Style', 'pushbutton', ...
        'String', '簡單 (180秒)', ...
        'Position', [125, 150, 120, 35], 'FontSize', 12, ...
        'Callback', @(~,~) startGame(180, true));
    
    % 普通模式按鈕
    uicontrol('Parent', difficultyFig, 'Style', 'pushbutton', ...
        'String', '普通 (120秒)', ...
        'Position', [125, 100, 120, 35], 'FontSize', 12, ...
        'Callback', @(~,~) startGame(120, true));
    
    % 困難模式按鈕
    uicontrol('Parent', difficultyFig, 'Style', 'pushbutton', ...
        'String', '困難 (60秒)', ...
        'Position', [125, 50, 120, 35], 'FontSize', 12, ...
        'Callback', @(~,~) startGame(60, false));
    
    function startGame(gameDuration, hintsEnabled)
        % 關閉難度選擇視窗
        close(difficultyFig);
        
        % 建立遊戲視窗
        fig = figure('Name', '元素合成遊戲', 'Position', [100, 100, 900, 700], ...
            'Color', [0.9 0.9 0.9], 'MenuBar', 'none', 'NumberTitle', 'off');
        
        % 建立遊戲區域
        ax = axes('Parent', fig, 'Position', [0.05, 0.15, 0.9, 0.8], ...
            'XLim', [0 900], 'YLim', [0 600], 'Color', [0.95 0.95 0.98]);
        
        % 創建漸變背景
        [X, Y] = meshgrid(linspace(0, 900, 20), linspace(0, 600, 20));
        Z = zeros(size(X));
        C = Y / 600; % 創建漸變效果
        surf(X, Y, Z, C, 'EdgeColor', 'none');
        colormap([linspace(0.9, 0.8, 256)', linspace(0.95, 0.85, 256)', linspace(1, 0.9, 256)']);
        
        view(2); % 2D視圖
        axis off;
        hold on;
        
        % 添加遊戲標題
        title('元素合成遊戲', 'FontSize', 18, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.6]);
        
        % 建立計時器顯示
        timerText = uicontrol('Style', 'text', 'Position', [350, 40, 150, 30], ...
            'FontSize', 14, 'FontWeight', 'bold', 'String', ['時間: ', num2str(gameDuration), '秒'], ...
            'BackgroundColor', [0.9 0.9 0.9]);
        
        % 建立分數顯示
        scoreText = uicontrol('Style', 'text', 'Position', [520, 40, 200, 30], ...
            'String', '分數: 0/10', 'FontSize', 14, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.9 0.9 0.9]);
        
        % 建立遊戲說明
        uicontrol('Style', 'text', 'Position', [50, 40, 200, 30], ...
            'String', '拖曳元素進行合成！', 'FontSize', 12, ...
            'BackgroundColor', [0.9 0.9 0.9]);
        
        % 添加提示按鈕
        if hintsEnabled
            hintButton = uicontrol('Style', 'pushbutton', 'String', '提示', ...
                'Position', [740, 40, 80, 30], 'FontSize', 12, 'Callback', @showHint);
        end
        
        % 添加教學按鈕
        tutorialButton = uicontrol('Style', 'pushbutton', 'String', '教學', ...
            'Position', [830, 40, 80, 30], 'FontSize', 12, 'Callback', @showTutorial);
        
        % 初始化遊戲變數
        gameTime = gameDuration; % 秒
        elementSize = [80, 80]; % 元素圖片尺寸
        elements = struct(); % 儲存元素資料的結構
        discoveredElements = {}; % 已發現元素列表
        draggingElement = ''; % 目前正在拖曳的元素
        isDragging = false; % 拖曳狀態標記
        offset = [0, 0]; % 拖曳偏移量
        combinationCount = 0; % 合成嘗試次數
        
        % 定義所有可能的合成組合
        combinations = struct();
        combinations(1).elements = {'water', 'fire'};
        combinations(1).result = 'steam';
        combinations(2).elements = {'dust', 'water'};
        combinations(2).result = 'plant';
        combinations(3).elements = {'fire', 'dust'};
        combinations(3).result = 'lava';
        combinations(4).elements = {'wind', 'water'};
        combinations(4).result = 'cloud';
        combinations(5).elements = {'metal', 'fire'};
        combinations(5).result = 'tool';
        combinations(6).elements = {'wood', 'fire'};
        combinations(6).result = 'charcoal';
        combinations(7).elements = {'wood', 'water'};
        combinations(7).result = 'boat';
        combinations(8).elements = {'water', 'plant'};
        combinations(8).result = 'fruit';
        combinations(9).elements = {'metal', 'tool'};
        combinations(9).result = 'mechanic';
        combinations(10).elements = {'steam', 'mechanic'};
        combinations(10).result = 'engine';
        
        % 載入基本元素（均勻分佈在遊戲區域的底部）
        baseElements = {'water', 'fire', 'dust', 'wind', 'metal', 'wood'};
        baseElementCount = length(baseElements);
        spacing = 850 / (baseElementCount + 1);
        
        for i = 1:baseElementCount
            xPos = i * spacing - elementSize(1)/2;
            loadElement(baseElements{i}, [xPos, 500]);
        end
        
        % 啟動遊戲計時器
        startTime = tic;
        timerID = timer('ExecutionMode', 'fixedRate', 'Period', 1, 'TimerFcn', @updateTimer);
        start(timerID);
        
        % 設定圖形介面回調函數
        set(fig, 'WindowButtonDownFcn', @startDrag);
        set(fig, 'WindowButtonUpFcn', @stopDrag);
        set(fig, 'WindowButtonMotionFcn', @updateDrag);
        
        % 更新分數顯示
        function updateScore()
            score = length(discoveredElements);
            totalCombinations = 10; % 總共可能的合成數
            set(scoreText, 'String', ['分數: ', num2str(score), '/', num2str(totalCombinations)]);
            
            % 檢查是否發現了所有元素
            if score == totalCombinations
                gameOver('恭喜！你發現了所有元素！', true);
            end
        end
        
        % 顯示教學
        function showTutorial(~, ~)
            tutorialFig = figure('Name', '遊戲教學', 'Position', [150, 150, 500, 400], ...
                'Color', [0.95 0.95 0.95], 'MenuBar', 'none', 'NumberTitle', 'off');
            
            tutorial = {
                '【元素合成遊戲教學】', 
                '', 
                '1. 遊戲目標：在限時內發現盡可能多的元素。', 
                '', 
                '2. 操作方式：點擊並拖曳元素到另一個元素上嘗試合成。', 
                '', 
                '3. 基本元素：水、火、土、風、金、木', 
                '', 
                '4. 合成示例：', 
                '   - 水 + 火 = 蒸氣', 
                '   - 土 + 水 = 植物', 
                '   ...等等！', 
                '', 
                '5. 提示功能：如果遇到困難，可以使用提示按鈕。', 
                '', 
                '6. 時間限制：遊戲時間有限，請把握時間！'
            };
            
            uicontrol('Parent', tutorialFig, 'Style', 'text', 'Position', [20, 60, 460, 320], ...
                'String', tutorial, 'FontSize', 12, 'HorizontalAlignment', 'left');
            
            uicontrol('Parent', tutorialFig, 'Style', 'pushbutton', 'String', '開始遊戲', ...
                'Position', [200, 20, 100, 30], 'Callback', @(~,~) close(tutorialFig));
        end
        
        % 顯示提示
        function showHint(~, ~)
            % 檢查已發現的元素
            if isempty(discoveredElements)
                % 還沒有發現元素，提示最基本的合成
                hintText = '提示：嘗試將水與火結合';
            else
                % 查找未發現的元素，提供相關提示
                allResults = {};
                for i = 1:length(combinations)
                    allResults{end+1} = combinations(i).result;
                end
                
                undiscoveredResults = setdiff(allResults, discoveredElements);
                
                if isempty(undiscoveredResults)
                    hintText = '恭喜！你已發現所有元素！';
                else
                    % 隨機選擇一個未發現的元素提供提示
                    randomResult = undiscoveredResults{randi(length(undiscoveredResults))};
                    
                    % 找出合成這個元素所需的材料
                    for i = 1:length(combinations)
                        if strcmp(combinations(i).result, randomResult)
                            hintCombination = combinations(i);
                            break;
                        end
                    end
                    
                    % 檢查是否擁有合成所需的元素
                    element1Exists = isfield(elements, hintCombination.elements{1});
                    element2Exists = isfield(elements, hintCombination.elements{2});
                    
                    if element1Exists && element2Exists
                        hintText = ['提示：嘗試將 ', translateElementName(hintCombination.elements{1}), ...
                                   ' 與 ', translateElementName(hintCombination.elements{2}), ' 結合'];
                    else
                        % 找出缺少哪個元素的提示
                        if ~element1Exists && ~element2Exists
                            hintText = '提示：你需要發現更多基本元素';
                        elseif ~element1Exists
                            hintText = ['提示：你需要先找到 ', translateElementName(hintCombination.elements{1})];
                        else
                            hintText = ['提示：你需要先找到 ', translateElementName(hintCombination.elements{2})];
                        end
                    end
                end
            end
            
            % 顯示提示
            hintFig = figure('Name', '合成提示', 'Position', [300, 300, 300, 150], ...
                'Color', [0.95 0.95 0.95], 'MenuBar', 'none', 'NumberTitle', 'off');
            
            uicontrol('Parent', hintFig, 'Style', 'text', 'Position', [20, 60, 260, 70], ...
                'String', hintText, 'FontSize', 12, 'HorizontalAlignment', 'center');
            
            uicontrol('Parent', hintFig, 'Style', 'pushbutton', 'String', '謝謝', ...
                'Position', [110, 20, 80, 30], 'Callback', @(~,~) close(hintFig));
        end
        
        % 翻譯元素名稱為中文
        function name = translateElementName(engName)
            switch engName
                case 'water'
                    name = '水';
                case 'fire'
                    name = '火';
                case 'dust'
                    name = '土';
                case 'wind'
                    name = '風';
                case 'metal'
                    name = '金';
                case 'wood'
                    name = '木';
                case 'steam'
                    name = '蒸氣';
                case 'plant'
                    name = '植物';
                case 'lava'
                    name = '岩漿';
                case 'cloud'
                    name = '雲';
                case 'tool'
                    name = '工具';
                case 'charcoal'
                    name = '木炭';
                case 'boat'
                    name = '船';
                case 'fruit'
                    name = '水果';
                case 'mechanic'
                    name = '機械';
                case 'engine'
                    name = '引擎';
                otherwise
                    name = engName; % 如果沒有匹配的翻譯，返回原名
            end
        end
        
        % 載入元素圖片和建立元素物件
        function loadElement(name, position)
            try
                % 檢查文件是否存在
                if ~exist([name, '.png'], 'file')
                    warning(['元素圖片不存在: ', name, '.png']);
                    
                    % 創建一個替代圖片
                    img = ones(elementSize(2), elementSize(1), 3);
                    alpha = ones(elementSize(2), elementSize(1));
                    
                    % 根據元素名稱設定不同顏色
                    switch name
                        case 'water'
                            color = [0, 0.4, 1]; % 藍色
                        case 'fire'
                            color = [1, 0.3, 0]; % 紅色
                        case 'dust'
                            color = [0.6, 0.3, 0]; % 棕色
                        case 'wind'
                            color = [0.8, 0.8, 1]; % 淺藍色
                        case 'metal'
                            color = [0.7, 0.7, 0.7]; % 灰色
                        case 'wood'
                            color = [0.5, 0.3, 0]; % 棕色
                        case 'steam'
                            color = [0.8, 0.8, 0.9]; % 淡灰色
                        case 'plant'
                            color = [0, 0.8, 0.2]; % 綠色
                        case 'lava'
                            color = [1, 0.4, 0]; % 橙紅色
                        case 'cloud'
                            color = [1, 1, 1]; % 白色
                        case 'tool'
                            color = [0.5, 0.5, 0.5]; % 灰色
                        case 'charcoal'
                            color = [0.2, 0.2, 0.2]; % 黑色
                        case 'boat'
                            color = [0.8, 0.6, 0.4]; % 淺棕色
                        case 'fruit'
                            color = [1, 0.6, 0]; % 橙色
                        case 'mechanic'
                            color = [0.4, 0.4, 0.6]; % 藍灰色
                        case 'engine'
                            color = [0.5, 0.5, 0.7]; % 紫灰色
                        otherwise
                            color = [rand, rand, rand]; % 隨機顏色
                    end
                    % 填充顏色
                    for i = 1:3
                        img(:,:,i) = color(i);
                    end
                    
                    % 使圖像周圍略微透明（創建圓形效果）
                    [xx, yy] = meshgrid(linspace(-1, 1, elementSize(1)), linspace(-1, 1, elementSize(2)));
                    mask = (xx.^2 + yy.^2) <= 1;
                    alpha = double(mask);
                else
                    % 正常載入圖片
                    [img, ~, alpha] = imread([name, '.png']);
                    img = imresize(img, elementSize);
                    alpha = imresize(alpha, elementSize);
                end
                
                % 建立元素的圖像物件
                h = image('XData', position(1) + [0, elementSize(1)], ...
                         'YData', position(2) + [0, elementSize(2)], ...
                         'CData', img, 'AlphaData', alpha);
                
                % 儲存元素資料
                elements.(name) = struct('handle', h, 'position', position, 'name', name);
                
                % 設定元素屬性
                set(h, 'Tag', name);
                
                % 如果是新的非基本元素，則添加到發現列表
                if ~ismember(name, baseElements) && ~ismember(name, discoveredElements)
                    discoveredElements{end+1} = name;
                    
                    % 更新分數
                    updateScore();
                    
                    % 顯示發現新元素的提示
                    if ~ismember(name, baseElements)
                        flashText = text(position(1) + elementSize(1)/2, position(2) - 20, ...
                            ['發現新元素：', translateElementName(name)], ...
                            'FontSize', 14, 'Color', [0, 0.6, 0], 'FontWeight', 'bold', ...
                            'HorizontalAlignment', 'center');
                        
                        % 淡出效果
                        for alpha = 1:-0.05:0
                            set(flashText, 'Color', [0, 0.6, 0, alpha]);
                            pause(0.05);
                        end
                        delete(flashText);
                    end
                end
                
            catch e
                warning(['載入元素時發生錯誤: ', name]);
                disp(e.message);
            end
        end
        
        % 開始拖曳元素
        function startDrag(~, ~)
            % 獲取被點擊的物件
            clickedObj = gco;
            if ~isempty(clickedObj) && strcmp(get(clickedObj, 'Type'), 'image')
                name = get(clickedObj, 'Tag');
                if isfield(elements, name)
                    % 開始拖曳
                    draggingElement = name;
                    isDragging = true;
                    currentPoint = get(ax, 'CurrentPoint');
                    elementPos = elements.(name).position;
                    offset = [currentPoint(1,1) - elementPos(1), currentPoint(1,2) - elementPos(2)];
                    
                    % 將元素置頂並增加其大小以視覺強調
                    uistack(elements.(name).handle, 'top');
                    
                    % 視覺反饋 - 稍微放大被拖曳的元素
                    currentXData = get(elements.(name).handle, 'XData');
                    currentYData = get(elements.(name).handle, 'YData');
                    width = currentXData(2) - currentXData(1);
                    height = currentYData(2) - currentYData(1);
                    
                    % 放大5%
                    newWidth = width * 1.05;
                    newHeight = height * 1.05;
                    newXData = [currentXData(1) - (newWidth - width)/2, currentXData(2) + (newWidth - width)/2];
                    newYData = [currentYData(1) - (newHeight - height)/2, currentYData(2) + (newHeight - height)/2];
                    
                    set(elements.(name).handle, 'XData', newXData, 'YData', newYData);
                end
            end
        end
        
        % 更新拖曳位置
        function updateDrag(~, ~)
            if isDragging && ~isempty(draggingElement)
                % 拖曳過程中更新元素位置
                currentPoint = get(ax, 'CurrentPoint');
                newPos = [currentPoint(1,1) - offset(1), currentPoint(1,2) - offset(2)];
                
                % 保持元素在界限內
                newPos(1) = max(0, min(newPos(1), 900 - elementSize(1)));
                newPos(2) = max(0, min(newPos(2), 600 - elementSize(2)));
                
                % 計算放大後的尺寸
                scaleFactor = 1.05;
                scaledSize = elementSize * scaleFactor;
                
                % 更新圖像位置
                set(elements.(draggingElement).handle, 'XData', newPos(1) + [0, scaledSize(1)], ...
                                                     'YData', newPos(2) + [0, scaledSize(2)]);
                
                % 更新儲存的位置
                elements.(draggingElement).position = newPos;
                
                % 視覺提示 - 檢查是否懸停在可合成的元素上
                hoverElement = findElementUnder(draggingElement);
                
                % 重置所有元素的外觀
                elementNames = fieldnames(elements);
                for i = 1:length(elementNames)
                    if ~strcmp(elementNames{i}, draggingElement)
                        % 恢復正常大小
                        pos = elements.(elementNames{i}).position;
                        set(elements.(elementNames{i}).handle, 'XData', pos(1) + [0, elementSize(1)], ...
                                                           'YData', pos(2) + [0, elementSize(2)]);
                    end
                end
                
                % 如果懸停在可合成的元素上，添加視覺提示
                if ~isempty(hoverElement)
                    % 檢查是否可以合成
                    canCombine = false;
                    for i = 1:length(combinations)
                        combo = combinations(i).elements;
                        if (strcmp(draggingElement, combo{1}) && strcmp(hoverElement, combo{2})) || ...
                           (strcmp(draggingElement, combo{2}) && strcmp(hoverElement, combo{1}))
                            canCombine = true;
                            break;
                        end
                    end
                    
                    if canCombine
                        % 視覺上強調可合成的元素 - 放大一點
                        pos = elements.(hoverElement).position;
                        set(elements.(hoverElement).handle, 'XData', pos(1) + [0, elementSize(1) * 1.1], ...
                                                       'YData', pos(2) + [0, elementSize(2) * 1.1]);
                    end
                end
            end
        end
        
        % 停止拖曳時嘗試合成
        function stopDrag(~, ~)
            if isDragging && ~isempty(draggingElement)
                % 檢查元素是否放在另一個元素上
                droppedOn = findElementUnder(draggingElement);
                
                % 恢復元素正常大小
                elementPos = elements.(draggingElement).position;
                set(elements.(draggingElement).handle, 'XData', elementPos(1) + [0, elementSize(1)], ...
                                                     'YData', elementPos(2) + [0, elementSize(2)]);
                
                if ~isempty(droppedOn)
                    % 嘗試合成元素
                    combineElements(draggingElement, droppedOn);
                    
                    % 恢復被拖放到的元素的正常大小
                    targetPos = elements.(droppedOn).position;
                    set(elements.(droppedOn).handle, 'XData', targetPos(1) + [0, elementSize(1)], ...
                                                   'YData', targetPos(2) + [0, elementSize(2)]);
                end
                
                % 重置拖曳狀態
                isDragging = false;
                draggingElement = '';
            end
        end
        
        % 查找當前元素下的目標元素
        function targetElement = findElementUnder(currentElement)
            % 查找當前元素下是否有其他元素
            currentPos = elements.(currentElement).position;
            currentCenter = currentPos + elementSize/2;
            
            targetElement = '';
            elementNames = fieldnames(elements);
            
            for i = 1:length(elementNames)
                name = elementNames{i};
                if strcmp(name, currentElement)
                    continue; % 跳過正在拖曳的元素
                end
                
                pos = elements.(name).position;
                elementCenter = pos + elementSize/2;
                
                % 檢查中心是否足夠接近
                if norm(currentCenter - elementCenter) < elementSize(1)/1.5
                    targetElement = name;
                    break;
                end
            end
        end
        
        % 合成元素
        function combineElements(element1, element2)
            % 增加合成嘗試計數
            combinationCount = combinationCount + 1;
            
            % 檢查所有可能的組合
            for i = 1:length(combinations)
                combo = combinations(i).elements;
                
                % 檢查這兩個元素是否匹配此組合（任意順序）
                if (strcmp(element1, combo{1}) && strcmp(element2, combo{2})) || ...
                   (strcmp(element1, combo{2}) && strcmp(element2, combo{1}))
                    
                    result = combinations(i).result;
                    
                    % 檢查我們是否已經有了這個結果
                    if ~isfield(elements, result)
                        % 顯示合成動畫
                        showCombinationAnimation(element1, element2, result);
                        
                        % 為結果創建一個新位置 - 嘗試將其放在兩個元素附近
                        pos1 = elements.(element1).position;
                        pos2 = elements.(element2).position;
                        midPos = (pos1 + pos2) / 2;
                        
                        % 添加一些隨機性以避免重疊
                        newPos = [midPos(1) + randi([-50, 50]), midPos(2) + randi([-50, 50])];
                        
                        % 保持在界限內
                        newPos(1) = max(20, min(newPos(1), 800 - elementSize(1)));
                        newPos(2) = max(20, min(newPos(2), 500 - elementSize(2)));
                        
                        % 添加新元素
                        loadElement(result, newPos);
                    else
                        % 已經有這個元素，顯示簡短的提示
                        midPos = (elements.(element1).position + elements.(element2).position) / 2;
                        t = text(midPos(1), midPos(2), '已發現過了！', ...
                             'FontSize', 14, 'HorizontalAlignment', 'center', ...
                             'FontWeight', 'bold', 'Color', [0.8, 0, 0]);
                        
                        % 短暫顯示後消失
                        pause(1);
                        delete(t);
                    end
                    return; % 找到匹配後退出
                end
            end
            
            % 如果沒有找到匹配
            midPos = (elements.(element1).position + elements.(element2).position) / 2;
            t = text(midPos(1), midPos(2), '這些元素不能合成！', ...
                 'FontSize', 14, 'HorizontalAlignment', 'center', ...
                 'FontWeight', 'bold', 'Color', [0.8, 0, 0]);
            
            % 短暫顯示後消失
            pause(1);
            delete(t);
        end
        
        % 顯示合成動畫
        function showCombinationAnimation(element1, element2, result)
            % 獲取元素中心的位置
            pos1 = elements.(element1).position + elementSize/2;
            pos2 = elements.(element2).position + elementSize/2;
            midPoint = (pos1 + pos2) / 2;
            
            % 1. 粒子效果
            numParticles = 30;
            particles = [];
            particleColors = [1 0.8 0; 1 0.6 0; 1 0.4 0]; % 黃到橙色的漸變
            
            % 創建從兩個元素發出的粒子
            for i = 1:numParticles
                % 隨機選擇一個顏色
                colorIdx = randi(3);
                color = particleColors(colorIdx, :);
                
                % 從第一個元素發出的粒子
                angle = 2 * pi * rand();
                distance = 20 * rand();
                pX = pos1(1) + distance * cos(angle);
                pY = pos1(2) + distance * sin(angle);
                particles(end+1) = plot(pX, pY, 'o', 'MarkerSize', 5, ...
                    'MarkerFaceColor', color, 'MarkerEdgeColor', 'none');
                
                % 從第二個元素發出的粒子
                angle = 2 * pi * rand();
                distance = 20 * rand();
                pX = pos2(1) + distance * cos(angle);
                pY = pos2(2) + distance * sin(angle);
                particles(end+1) = plot(pX, pY, 'o', 'MarkerSize', 5, ...
                    'MarkerFaceColor', color, 'MarkerEdgeColor', 'none');
            end
            
            % 粒子向中心移動的動畫
            steps = 15;
            
            for step = 1:steps
                for i = 1:length(particles)
                    p = particles(i);
                    currentPos = [get(p, 'XData'), get(p, 'YData')];
                    newPos = currentPos + (midPoint - currentPos) * 0.2;
                    set(p, 'XData', newPos(1), 'YData', newPos(2));
                    
                    % 粒子逐漸變大
                    currentSize = get(p, 'MarkerSize');
                    set(p, 'MarkerSize', currentSize * 1.05);
                end
                drawnow;
                pause(0.02);
            end
            
            % 爆炸效果
            for i = 1:length(particles)
                set(particles(i), 'MarkerSize', 20, 'MarkerFaceColor', [1 0.6 0]);
            end
            
            % 閃光效果
            flash = rectangle('Position', [midPoint(1)-50, midPoint(2)-50, 100, 100], ...
                'Curvature', [1 1], 'FaceColor', [1 1 0.8], 'EdgeColor', 'none');
            
            for i = 1:5
                set(flash, 'FaceColor', [1 1-i*0.15 0.8-i*0.15]);
                set(flash, 'Position', [midPoint(1)-50+i*5, midPoint(2)-50+i*5, 100-i*10, 100-i*10]);
                drawnow;
                pause(0.05);
            end
            
            % 清理動畫元素
            for i = 1:length(particles)
                delete(particles(i));
            end
            delete(flash);
            
            % 顯示合成結果
            resultText = [translateElementName(element1), ' + ', translateElementName(element2), ...
                     ' = ', translateElementName(result)];
            t = text(midPoint(1), midPoint(2), resultText, ...
                 'FontSize', 16, 'HorizontalAlignment', 'center', ...
                 'FontWeight', 'bold', 'BackgroundColor', [1 1 0.8]);
            
            % 讓文字可見片刻，然後淡出
            pause(1.5);
            delete(t);
        end
        
        % 更新計時器
        function updateTimer(~, ~)
            % 更新計時器顯示
            elapsed = toc(startTime);
            remaining = max(0, gameTime - elapsed);
            set(timerText, 'String', ['時間: ', num2str(ceil(remaining)), '秒']);
            
            % 改變時間文字顏色來提醒玩家
            if remaining <= 10
                set(timerText, 'ForegroundColor', [1, 0, 0]); % 紅色警告
            elseif remaining <= 30
                set(timerText, 'ForegroundColor', [1, 0.5, 0]); % 橙色警告
            end
            
            % 檢查時間是否用完
            if remaining <= 0
                if isvalid(timerID)
                    stop(timerID);
                    delete(timerID);
                end
                gameOver('時間到！', false);
            end
        end
        
        % 遊戲結束
        function gameOver(message, isSuccess)
            % 如果計時器仍在運行，則停止它
            if isvalid(timerID)
                stop(timerID);
                delete(timerID);
            end
            
            % 建立已發現元素列表
            if isempty(discoveredElements)
                discList = '(無)';
            else
                discList = '';
                for i = 1:length(discoveredElements)
                    if i > 1
                        discList = [discList, ', '];
                    end
                    discList = [discList, translateElementName(discoveredElements{i})];
                end
            end
            
            % 準備結果訊息
            resultMessage = {
                message,
                ['最終分數: ', num2str(length(discoveredElements)), '/10'],
                '',
                '已發現元素:',
                discList
            };
            
            % 顯示遊戲結束訊息
            f = msgbox(resultMessage, '遊戲結束', 'help');
            % 增加訊息框大小以適應內容
            pos = get(f, 'Position');
            set(f, 'Position', [pos(1), pos(2)-100, pos(3)+150, pos(4)+100]);
            
            % 在主遊戲視窗上顯示重新開始按鈕
            restartButton = uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', '重新開始', ...
                'Position', [350, 40, 150, 30], 'FontSize', 14, 'FontWeight', 'bold', ...
                'Callback', @restartGame);
        end
        
        % 重新開始遊戲
        function restartGame(~, ~)
            % 關閉當前圖形並開始新遊戲
            close(fig);
            elementGame();
        end
    end
end