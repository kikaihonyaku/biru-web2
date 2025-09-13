import React, { useState } from "react";
import {
  ThemeProvider,
  CssBaseline,
  Box,
  useMediaQuery,
  Fade,
  Button,
  Paper,
  Collapse,
  Typography,
  IconButton,
  Tooltip,
} from '@mui/material';
import { 
  Fullscreen as FullscreenIcon,
  FullscreenExit as FullscreenExitIcon 
} from '@mui/icons-material';
import muiTheme from '../theme/muiTheme';
import Header from "../components/shared/Header";
import MapContainer from "../components/MapSystem/MapContainer";
import LeftPanel from "../components/MapSystem/LeftPanel/LeftPanel";
import PropertyTable from "../components/MapSystem/BottomPanel/PropertyTable";
import MapTest from "../components/MapSystem/MapTest";
import { useMapData } from '../hooks/useMapData';

export default function MapSystem() {
  const [leftPanelPinned, setLeftPanelPinned] = useState(true);
  const [bottomPanelVisible, setBottomPanelVisible] = useState(false);
  const [selectedObject, setSelectedObject] = useState(null);
  const [selectedLayers, setSelectedLayers] = useState([]);
  const [showDebugMode, setShowDebugMode] = useState(false);
  const [rightPanelVisible, setRightPanelVisible] = useState(false);
  const [leftPanelHovered, setLeftPanelHovered] = useState(false);
  const [headerVisible, setHeaderVisible] = useState(false);
  const [propertyListMaximized, setPropertyListMaximized] = useState(false);
  
  // useMapDataフックを使用してデータ管理
  const { 
    properties, 
    isLoading, 
    error, 
    searchConditions, 
    searchProperties 
  } = useMapData();
  
  // レスポンシブ設定
  const isMdUp = useMediaQuery(muiTheme.breakpoints.up('md'));
  const isSmUp = useMediaQuery(muiTheme.breakpoints.up('sm'));

  const handleMarkerSelect = (type, data) => {
    setSelectedObject({ type, data });
  };

  const handleSearch = async (conditions) => {
    try {
      await searchProperties(conditions);
    } catch (error) {
      console.error('Search error:', error);
      // エラーハンドリングは後で追加
    }
  };

  const handleLayerToggle = (layerId, enabled) => {
    setSelectedLayers(prev => {
      if (enabled) {
        return [...prev, layerId];
      } else {
        return prev.filter(id => id !== layerId);
      }
    });
    // ここでレイヤーの表示を切り替える処理を追加
    console.log('Layer toggled:', layerId, enabled);
  };

  const handleTogglePin = () => {
    setLeftPanelPinned(!leftPanelPinned);
  };

  const handleToggleBottomPanel = () => {
    setBottomPanelVisible(!bottomPanelVisible);
  };

  const handleTogglePropertyListMaximize = () => {
    setPropertyListMaximized(!propertyListMaximized);
    // 最大化時は下ペインを非表示に
    if (!propertyListMaximized) {
      setBottomPanelVisible(false);
    } else {
      // 最小化時（最大化を解除時）は下ペインを表示
      setBottomPanelVisible(true);
    }
  };

  const handleClosePropertyList = () => {
    setPropertyListMaximized(false);
    setBottomPanelVisible(false);
  };

  // デバッグモード表示
  if (showDebugMode) {
    return (
      <ThemeProvider theme={muiTheme}>
        <CssBaseline />
        <Box sx={{ padding: 3 }}>
          <Button
            variant="contained"
            onClick={() => setShowDebugMode(false)}
            sx={{ mb: 2 }}
          >
            ← 地図システムに戻る
          </Button>
          <MapTest />
        </Box>
      </ThemeProvider>
    );
  }

  return (
    <ThemeProvider theme={muiTheme}>
      <CssBaseline />
      <Box sx={{ display: 'flex', flexDirection: 'column', height: '100vh' }}>
        {/* ヘッダーホバーエリア */}
        <Box
          sx={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            height: '20px',
            zIndex: 2200,
            pointerEvents: 'all',
          }}
          onMouseEnter={() => setHeaderVisible(true)}
          onMouseLeave={() => setHeaderVisible(false)}
        />
        
        {/* ヘッダーエリア */}
        <Fade in={headerVisible} timeout={200}>
          <Box 
            sx={{ 
              position: 'fixed',
              top: headerVisible ? 0 : '-60px',
              left: 0,
              right: 0,
              zIndex: 2100, 
              transition: 'top 0.2s ease-in-out',
            }}
            onMouseEnter={() => setHeaderVisible(true)}
            onMouseLeave={() => setHeaderVisible(false)}
          >
            <Header />
          </Box>
        </Fade>
        
        {/* コンテンツエリア */}
        <Box
          sx={{
            display: 'flex',
            flex: 1,
            overflow: 'hidden',
            bgcolor: 'background.default',
            paddingTop: headerVisible ? '45px' : '0px',
            transition: 'padding-top 0.2s ease-in-out',
          }}
        >
        {/* メインコンテンツエリア */}
        <Box
          sx={{
            display: 'flex',
            flexDirection: 'column',
            flex: 1,
            overflow: 'hidden',
            position: 'relative',
          }}
        >
          {/* 左ペイン（ピン止め時・フローティング時共通） */}
          <LeftPanel
            isPinned={leftPanelPinned}
            onTogglePin={handleTogglePin}
            onSearch={handleSearch}
            onLayerToggle={handleLayerToggle}
            searchConditions={searchConditions}
            selectedLayers={selectedLayers}
            onHoverChange={setLeftPanelHovered}
            isLoading={isLoading}
            error={error}
          />
          {/* 上部エリア（地図 + 右ペイン） */}
          <Box
            sx={{
              display: 'flex',
              flex: 1,
              overflow: 'hidden',
              marginLeft: leftPanelPinned ? '323px' : '0px',
              transition: 'margin-left 0.3s ease',
            }}
          >
            {/* 中央の地図エリア */}
            <Box sx={{ flex: 1, position: 'relative' }}>
              {propertyListMaximized ? (
                /* 最大化された物件一覧 */
                <Fade in={true} timeout={300}>
                  <Paper 
                    elevation={2}
                    sx={{ 
                      position: 'absolute',
                      top: '2px',
                      left: '2px',
                      right: rightPanelVisible && isMdUp ? '4px' : '2px',
                      bottom: '2px',
                      display: 'flex',
                      flexDirection: 'column',
                      overflow: 'hidden'
                    }}
                  >
                  <Box sx={{ 
                    bgcolor: 'primary.main',
                    color: 'white',
                    px: 2,
                    py: 0.5,
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    minHeight: '40px'
                  }}>
                    <Box component="h3" sx={{ m: 0, fontSize: '1rem', fontWeight: 600 }}>
                      物件一覧（最大化表示）
                    </Box>
                    <Box sx={{ display: 'flex', gap: 1 }}>
                      <Tooltip title="元に戻す" placement="top">
                        <Button
                          size="small"
                          onClick={handleTogglePropertyListMaximize}
                          sx={{ 
                            color: 'white', 
                            minWidth: 'auto', 
                            p: 0.5,
                            '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.1)' }
                          }}
                        >
                          <FullscreenExitIcon fontSize="small" />
                        </Button>
                      </Tooltip>
                      <Tooltip title="閉じる" placement="top">
                        <Button
                          size="small"
                          onClick={handleClosePropertyList}
                          sx={{ 
                            color: 'white', 
                            minWidth: 'auto', 
                            p: 0.5,
                            '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.1)' }
                          }}
                        >
                          ✕
                        </Button>
                      </Tooltip>
                    </Box>
                  </Box>
                  <Box sx={{ flex: 1, overflow: 'auto' }}>
                    <PropertyTable
                      properties={properties}
                      onPropertySelect={(property) => {
                        setSelectedObject({ type: 'property', data: property });
                        setRightPanelVisible(true);
                      }}
                      searchConditions={searchConditions}
                    />
                  </Box>
                  </Paper>
                </Fade>
              ) : (
                /* 通常の地図表示 */
                <MapContainer 
                  onMarkerSelect={handleMarkerSelect}
                  rightPanelVisible={rightPanelVisible}
                  onToggleRightPanel={() => setRightPanelVisible(true)}
                  selectedObject={selectedObject}
                  properties={properties}
                  isLoading={isLoading}
                />
              )}
            </Box>

            {/* 右ペイン */}
            {rightPanelVisible && (
              <Fade in={true}>
                <Paper
                  elevation={2}
                  sx={{
                    width: isMdUp ? 320 : '100%',
                    position: isMdUp ? 'relative' : 'absolute',
                    top: isMdUp ? '2px' : '2px',
                    right: isMdUp ? '2px' : '2px',
                    height: isMdUp ? 'calc(100% - 4px)' : 'auto',
                    maxHeight: isMdUp ? 'calc(100% - 4px)' : '80%',
                    zIndex: isMdUp ? 'auto' : 1300,
                    display: 'flex',
                    flexDirection: 'column',
                    overflow: 'hidden',
                  }}
                >
                  <Box
                    sx={{
                      bgcolor: 'primary.main',
                      color: 'white',
                      px: 2,
                      py: 0.5,
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                      minHeight: '40px',
                    }}
                  >
                    <Box component="h3" sx={{ m: 0, fontSize: '1rem', fontWeight: 600 }}>
                      物件詳細
                    </Box>
                    <Button
                      size="small"
                      onClick={() => setRightPanelVisible(false)}
                      sx={{ 
                        color: 'white', 
                        minWidth: 'auto', 
                        p: 0.5,
                        '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.1)' }
                      }}
                      title="物件詳細を閉じる"
                    >
                      ✕
                    </Button>
                  </Box>
                  
                  <Box sx={{ p: 2, flex: 1, overflow: 'auto' }}>
                    {selectedObject ? (
                      <Box>
                        {selectedObject.type === 'property' && (
                          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                            <Paper variant="outlined" sx={{ p: 2 }}>
                              <Box sx={{ fontWeight: 600, fontSize: '0.75rem', color: 'text.secondary', mb: 0.5 }}>
                                物件名
                              </Box>
                              <Box sx={{ fontSize: '1rem', color: 'text.primary' }}>
                                {selectedObject.data.name}
                              </Box>
                            </Paper>
                            
                            <Paper variant="outlined" sx={{ p: 2 }}>
                              <Box sx={{ fontWeight: 600, fontSize: '0.75rem', color: 'text.secondary', mb: 0.5 }}>
                                住所
                              </Box>
                              <Box sx={{ fontSize: '1rem', color: 'text.primary' }}>
                                {selectedObject.data.address}
                              </Box>
                            </Paper>
                            
                            <Paper variant="outlined" sx={{ p: 2 }}>
                              <Box sx={{ fontWeight: 600, fontSize: '0.75rem', color: 'text.secondary', mb: 0.5 }}>
                                建物種別
                              </Box>
                              <Box sx={{ fontSize: '1rem', color: 'text.primary' }}>
                                {selectedObject.data.type === 'apartment' ? 'アパート' : 
                                 selectedObject.data.type === 'mansion' ? 'マンション' : 
                                 selectedObject.data.type === 'house' ? '戸建て' : '不明'}
                              </Box>
                            </Paper>
                            
                            <Box sx={{ display: 'flex', gap: 1 }}>
                              <Paper variant="outlined" sx={{ p: 2, flex: 1 }}>
                                <Box sx={{ fontWeight: 600, fontSize: '0.75rem', color: 'text.secondary', mb: 0.5 }}>
                                  総戸数
                                </Box>
                                <Box sx={{ fontSize: '1rem', color: 'text.primary' }}>
                                  {selectedObject.data.rooms}戸
                                </Box>
                              </Paper>
                              
                              <Paper variant="outlined" sx={{ p: 2, flex: 1 }}>
                                <Box sx={{ fontWeight: 600, fontSize: '0.75rem', color: 'text.secondary', mb: 0.5 }}>
                                  空室数
                                </Box>
                                <Box sx={{ fontSize: '1rem', color: 'text.primary' }}>
                                  {selectedObject.data.vacantRooms}戸
                                </Box>
                              </Paper>
                            </Box>
                            
                            <Paper variant="outlined" sx={{ p: 2 }}>
                              <Box sx={{ fontWeight: 600, fontSize: '0.75rem', color: 'text.secondary', mb: 0.5 }}>
                                空室率
                              </Box>
                              <Box sx={{ fontSize: '1rem', color: 'text.primary' }}>
                                {((selectedObject.data.vacantRooms / selectedObject.data.rooms) * 100).toFixed(1)}%
                              </Box>
                            </Paper>
                            
                            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1, mt: 2 }}>
                              <Button variant="contained" fullWidth>
                                詳細ページを開く
                              </Button>
                              <Button variant="outlined" fullWidth>
                                ストリートビュー表示
                              </Button>
                            </Box>
                          </Box>
                        )}
                      </Box>
                    ) : (
                      <Paper
                        variant="outlined"
                        sx={{
                          p: 3,
                          textAlign: 'center',
                          color: 'text.secondary',
                          border: '2px dashed',
                          borderColor: 'grey.300',
                        }}
                      >
                        地図上の物件を選択してください
                      </Paper>
                    )}
                  </Box>
                </Paper>
              </Fade>
            )}
          </Box>

          {/* 下ペイン - 最大化時は非表示 */}
          {(!leftPanelPinned || isMdUp) && !propertyListMaximized && (
            <Collapse in={bottomPanelVisible}>
              <Paper
                elevation={2}
                sx={{
                  maxHeight: '40vh',
                  display: 'flex',
                  flexDirection: 'column',
                  overflow: 'hidden',
                  zIndex: 1200,
                  position: 'relative',
                  marginLeft: leftPanelPinned ? '324px' : '0px',
                  marginRight: '1px',
                  transition: 'margin-left 0.3s ease',
                }}
              >
                <Box
                  sx={{
                    bgcolor: 'primary.main',
                    color: 'white',
                    px: 2,
                    py: 0.5,
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    minHeight: '40px',
                  }}
                >
                  <Box component="h3" sx={{ m: 0, fontSize: '1rem', fontWeight: 600 }}>
                    物件一覧
                  </Box>
                  <Box sx={{ display: 'flex', gap: 1 }}>
                    <Tooltip title="最大化" placement="top">
                      <IconButton
                        size="small"
                        onClick={handleTogglePropertyListMaximize}
                        sx={{ 
                          color: 'white',
                          '&:hover': {
                            backgroundColor: 'rgba(255, 255, 255, 0.1)'
                          }
                        }}
                      >
                        <FullscreenIcon fontSize="small" />
                      </IconButton>
                    </Tooltip>
                    <Button
                      size="small"
                      onClick={() => setBottomPanelVisible(false)}
                      sx={{ color: 'white', minWidth: 'auto', p: 0.5 }}
                      title="閉じる"
                    >
                      ✕
                    </Button>
                  </Box>
                </Box>
                <Box sx={{ flex: 1, overflow: 'auto' }}>
                  <PropertyTable
                    properties={properties}
                    onPropertySelect={(property) => {
                      setSelectedObject({ type: 'property', data: property });
                      setRightPanelVisible(true);
                    }}
                    searchConditions={searchConditions}
                  />
                </Box>
              </Paper>
            </Collapse>
          )}
        </Box>

        {/* 下ペイン表示ボタン（非表示時かつ非最大化時） */}
        {!bottomPanelVisible && !propertyListMaximized && (
          <Box
            sx={{
              position: 'fixed',
              bottom: 0,
              left: 0,
              right: 0,
              height: '80px',
              pointerEvents: 'none', // 背景はクリック不可
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              paddingLeft: leftPanelPinned || leftPanelHovered ? '320px' : '60px',
              transition: 'padding-left 0.3s ease',
              zIndex: 1000,
            }}
          >
            <Fade in={true}>
              <Button
                variant="contained"
                onClick={() => {
                  setBottomPanelVisible(true);
                  if (selectedObject) {
                    setRightPanelVisible(true);
                  }
                }}
                sx={{
                  pointerEvents: 'all', // ボタンのみクリック可能
                  borderRadius: '25px',
                  px: 3,
                  py: 1.5,
                }}
              >
                物件一覧を表示
              </Button>
            </Fade>
          </Box>
        )}
        
        </Box>
      </Box>
    </ThemeProvider>
  );
}