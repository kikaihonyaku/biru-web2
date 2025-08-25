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
} from '@mui/material';
import muiTheme from '../theme/muiTheme';
import MapContainer from "../components/MapSystem/MapContainer";
import LeftPanel from "../components/MapSystem/LeftPanel/LeftPanel";
import PropertyTable from "../components/MapSystem/BottomPanel/PropertyTable";
import MapTest from "../components/MapSystem/MapTest";

export default function MapSystem() {
  const [leftPanelPinned, setLeftPanelPinned] = useState(false);
  const [bottomPanelVisible, setBottomPanelVisible] = useState(true);
  const [selectedObject, setSelectedObject] = useState(null);
  const [searchConditions, setSearchConditions] = useState({});
  const [selectedLayers, setSelectedLayers] = useState([]);
  const [showDebugMode, setShowDebugMode] = useState(false);
  const [rightPanelVisible, setRightPanelVisible] = useState(true);
  const [leftPanelHovered, setLeftPanelHovered] = useState(false);
  
  // レスポンシブ設定
  const isMdUp = useMediaQuery(muiTheme.breakpoints.up('md'));
  const isSmUp = useMediaQuery(muiTheme.breakpoints.up('sm'));

  const handleMarkerSelect = (type, data) => {
    setSelectedObject({ type, data });
  };

  const handleSearch = (conditions) => {
    setSearchConditions(conditions);
    // ここで地図の表示を更新する処理を追加
    console.log('Search conditions:', conditions);
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
      <Box
        sx={{
          display: 'flex',
          height: 'calc(100vh - 64px)', // ヘッダー分を除いた高さ
          overflow: 'hidden',
          bgcolor: 'background.default',
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
          />
          {/* 上部エリア（地図 + 右ペイン） */}
          <Box
            sx={{
              display: 'flex',
              flex: 1,
              overflow: 'hidden',
              marginLeft: leftPanelPinned ? '320px' : '0px',
              transition: 'margin-left 0.3s ease',
            }}
          >
            {/* 中央の地図エリア */}
            <Box sx={{ flex: 1, position: 'relative' }}>
              <MapContainer 
                onMarkerSelect={handleMarkerSelect}
                rightPanelVisible={rightPanelVisible}
                onToggleRightPanel={() => setRightPanelVisible(true)}
                selectedObject={selectedObject}
              />
            </Box>

            {/* 右ペイン */}
            {rightPanelVisible && (
              <Fade in={true}>
                <Paper
                  elevation={2}
                  sx={{
                    width: isMdUp ? 320 : '100%',
                    position: isMdUp ? 'relative' : 'absolute',
                    top: isMdUp ? 'auto' : 0,
                    right: 0,
                    height: isMdUp ? '100%' : 'auto',
                    maxHeight: isMdUp ? '100%' : '80%',
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
                      py: 0.75,
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
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

          {/* 下ペイン */}
          {(!leftPanelPinned || isMdUp) && (
            <Collapse in={bottomPanelVisible}>
              <Paper
                elevation={2}
                sx={{
                  maxHeight: '40vh',
                  display: 'flex',
                  flexDirection: 'column',
                  borderRadius: 0,
                  zIndex: 1200,
                  position: 'relative',
                  marginLeft: leftPanelPinned ? '320px' : '0px',
                  transition: 'margin-left 0.3s ease',
                }}
              >
                <Box
                  sx={{
                    bgcolor: 'primary.main',
                    color: 'white',
                    px: 2,
                    py: 0.75,
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                  }}
                >
                  <Box component="h3" sx={{ m: 0, fontSize: '1rem', fontWeight: 600 }}>
                    物件一覧
                  </Box>
                  <Button
                    size="small"
                    onClick={() => setBottomPanelVisible(false)}
                    sx={{ color: 'white', minWidth: 'auto', p: 0.5 }}
                  >
                    ✕
                  </Button>
                </Box>
                <Box sx={{ flex: 1, overflow: 'auto' }}>
                  <PropertyTable
                    onPropertySelect={(property) => {
                      setSelectedObject({ type: 'property', data: property });
                    }}
                    searchConditions={searchConditions}
                  />
                </Box>
              </Paper>
            </Collapse>
          )}
        </Box>

        {/* 下ペイン表示ボタン（非表示時） */}
        {!bottomPanelVisible && (
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
                onClick={() => setBottomPanelVisible(true)}
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
        
        
        {/* デバッグボタン */}
        <Button
          variant="contained"
          color="error"
          size="small"
          onClick={() => setShowDebugMode(true)}
          sx={{
            position: 'fixed',
            top: 10,
            right: 10,
            zIndex: 2000,
            fontSize: '0.75rem',
            px: 1.5,
            py: 0.5,
          }}
        >
          🐛 Debug
        </Button>
      </Box>
    </ThemeProvider>
  );
}