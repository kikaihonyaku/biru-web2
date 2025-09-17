import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
  ThemeProvider,
  CssBaseline,
  Box,
  AppBar,
  Toolbar,
  Typography,
  IconButton,
  Button,
  Paper,
  Divider,
  Snackbar,
  Alert,
  CircularProgress,
  useMediaQuery,
} from '@mui/material';
import {
  ArrowBack as ArrowBackIcon,
  Save as SaveIcon,
  Edit as EditIcon,
  Map as MapIcon,
  PhotoLibrary as PhotoLibraryIcon,
} from '@mui/icons-material';
import muiTheme from '../theme/muiTheme';
import { useAuth } from '../contexts/AuthContext';

// 子コンポーネントのインポート（後で作成）
import PropertyInfoPanel from '../components/PropertyDetail/PropertyInfoPanel';
import PropertyMapPanel from '../components/PropertyDetail/PropertyMapPanel';
import RoomsPanel from '../components/PropertyDetail/RoomsPanel';
import PhotosPanel from '../components/PropertyDetail/PhotosPanel';

export default function PropertyDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  
  // 状態管理
  const [property, setProperty] = useState(null);
  const [rooms, setRooms] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const [editMode, setEditMode] = useState(false);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  
  // レスポンシブ設定
  const isMdUp = useMediaQuery(muiTheme.breakpoints.up('md'));
  const isLgUp = useMediaQuery(muiTheme.breakpoints.up('lg'));
  
  // データ取得
  useEffect(() => {
    fetchPropertyData();
  }, [id]);
  
  const fetchPropertyData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // 物件詳細データ取得
      const propertyResponse = await fetch(`/api/v1/properties/${id}`);
      if (!propertyResponse.ok) {
        throw new Error('物件データの取得に失敗しました');
      }
      const propertyData = await propertyResponse.json();
      setProperty(propertyData.data);
      
      // 部屋データ取得
      const roomsResponse = await fetch(`/api/v1/properties/${id}/rooms`);
      if (!roomsResponse.ok) {
        throw new Error('部屋データの取得に失敗しました');
      }
      const roomsData = await roomsResponse.json();
      setRooms(roomsData.data);
      
    } catch (err) {
      setError(err.message);
      showSnackbar(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };
  
  const handleSave = async (formData) => {
    try {
      setSaving(true);
      
      const response = await fetch(`/api/v1/properties/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ property: formData }),
      });
      
      if (!response.ok) {
        throw new Error('保存に失敗しました');
      }
      
      const result = await response.json();
      setProperty(result.data);
      setEditMode(false);
      showSnackbar('物件情報を保存しました', 'success');
      
    } catch (err) {
      showSnackbar(err.message, 'error');
    } finally {
      setSaving(false);
    }
  };
  
  const handleRoomUpdate = async () => {
    // 部屋データを再取得
    try {
      const roomsResponse = await fetch(`/api/v1/properties/${id}/rooms`);
      if (roomsResponse.ok) {
        const roomsData = await roomsResponse.json();
        setRooms(roomsData.data);
      }
    } catch (err) {
      console.error('部屋データの更新に失敗:', err);
    }
  };
  
  const showSnackbar = (message, severity = 'success') => {
    setSnackbar({ open: true, message, severity });
  };
  
  const handleCloseSnackbar = () => {
    setSnackbar({ ...snackbar, open: false });
  };
  
  if (loading) {
    return (
      <ThemeProvider theme={muiTheme}>
        <CssBaseline />
        <Box 
          display="flex" 
          justifyContent="center" 
          alignItems="center" 
          minHeight="100vh"
          bgcolor="background.default"
        >
          <CircularProgress size={60} />
        </Box>
      </ThemeProvider>
    );
  }
  
  if (error || !property) {
    return (
      <ThemeProvider theme={muiTheme}>
        <CssBaseline />
        <Box 
          display="flex" 
          flexDirection="column"
          justifyContent="center" 
          alignItems="center" 
          minHeight="100vh"
          bgcolor="background.default"
          gap={2}
        >
          <Typography variant="h6" color="error">
            {error || '物件が見つかりません'}
          </Typography>
          <Button variant="contained" onClick={() => navigate('/map')}>
            地図に戻る
          </Button>
        </Box>
      </ThemeProvider>
    );
  }
  
  return (
    <ThemeProvider theme={muiTheme}>
      <CssBaseline />
      <Box sx={{ display: 'flex', flexDirection: 'column', height: '100vh', bgcolor: 'background.default' }}>
        
        {/* ヘッダー */}
        <AppBar position="static" elevation={1} sx={{ bgcolor: 'primary.main', borderBottom: '1px solid #ddd' }}>
          <Toolbar variant="dense" sx={{ minHeight: '56px' }}>
            <IconButton
              edge="start"
              color="inherit"
              onClick={() => navigate('/map')}
              sx={{ mr: 2 }}
            >
              <ArrowBackIcon />
            </IconButton>
            
            <Box sx={{ flexGrow: 1 }}>
              <Typography variant="h6" component="h1" sx={{ fontWeight: 600 }}>
                {property.name}
              </Typography>
              <Typography variant="body2" sx={{ opacity: 0.8, fontSize: '0.875rem' }}>
                {property.address}
              </Typography>
            </Box>
            
            <Box sx={{ display: 'flex', gap: 1 }}>
              {editMode ? (
                <>
                  <Button
                    variant="outlined"
                    size="small"
                    onClick={() => setEditMode(false)}
                    sx={{ color: 'white', borderColor: 'white' }}
                  >
                    キャンセル
                  </Button>
                  <Button
                    variant="contained"
                    size="small"
                    startIcon={saving ? <CircularProgress size={16} /> : <SaveIcon />}
                    disabled={saving}
                    sx={{ bgcolor: 'white', color: 'primary.main', '&:hover': { bgcolor: 'grey.100' } }}
                  >
                    保存
                  </Button>
                </>
              ) : (
                <Button
                  variant="outlined"
                  size="small"
                  startIcon={<EditIcon />}
                  onClick={() => setEditMode(true)}
                  sx={{ color: 'white', borderColor: 'white' }}
                >
                  編集
                </Button>
              )}
            </Box>
          </Toolbar>
        </AppBar>
        
        {/* メインコンテンツ */}
        <Box sx={{ display: 'flex', flex: 1, overflow: 'hidden' }}>
          
          {/* 左パネル - 物件情報 */}
          <Paper 
            elevation={2}
            sx={{ 
              width: isLgUp ? 380 : isMdUp ? 320 : '100%',
              display: isMdUp ? 'block' : editMode ? 'block' : 'none',
              borderRadius: 0,
              overflow: 'auto'
            }}
          >
            <PropertyInfoPanel
              property={property}
              editMode={editMode}
              onSave={handleSave}
              loading={saving}
            />
          </Paper>
          
          {/* 中央パネル - 地図と写真 */}
          <Box sx={{ 
            flex: 1, 
            display: 'flex', 
            flexDirection: 'column',
            overflow: 'hidden'
          }}>
            {/* 地図エリア */}
            <Paper 
              elevation={1}
              sx={{ 
                flex: 1,
                borderRadius: 0,
                position: 'relative'
              }}
            >
              <PropertyMapPanel
                property={property}
                onLocationUpdate={(lat, lng) => {
                  setProperty(prev => ({ ...prev, latitude: lat, longitude: lng }));
                }}
              />
            </Paper>
            
            {/* 写真エリア */}
            {isLgUp && (
              <Paper 
                elevation={1}
                sx={{ 
                  height: 200,
                  borderRadius: 0,
                  borderTop: '1px solid #ddd'
                }}
              >
                <PhotosPanel
                  propertyId={id}
                  editMode={editMode}
                  onPhotosUpdate={() => {}}
                />
              </Paper>
            )}
          </Box>
          
          {/* 右パネル - 部屋一覧 */}
          <Paper 
            elevation={2}
            sx={{ 
              width: isLgUp ? 400 : isMdUp ? 350 : '100%',
              display: isMdUp ? 'block' : !editMode ? 'block' : 'none',
              borderRadius: 0,
              overflow: 'auto'
            }}
          >
            <RoomsPanel
              propertyId={id}
              rooms={rooms}
              onRoomsUpdate={handleRoomUpdate}
              editMode={editMode}
            />
          </Paper>
        </Box>
        
        {/* スマートフォン用ナビゲーション */}
        {!isMdUp && (
          <Paper 
            elevation={3}
            sx={{ 
              display: 'flex',
              justifyContent: 'space-around',
              p: 1,
              borderRadius: 0
            }}
          >
            <Button
              size="small"
              startIcon={<EditIcon />}
              onClick={() => setEditMode(!editMode)}
              variant={editMode ? "contained" : "outlined"}
            >
              編集
            </Button>
            <Button
              size="small"
              startIcon={<MapIcon />}
              onClick={() => {/* 地図表示切り替え */}}
            >
              地図
            </Button>
            <Button
              size="small"
              startIcon={<PhotoLibraryIcon />}
              onClick={() => {/* 写真表示切り替え */}}
            >
              写真
            </Button>
          </Paper>
        )}
        
        {/* スナックバー */}
        <Snackbar
          open={snackbar.open}
          autoHideDuration={6000}
          onClose={handleCloseSnackbar}
          anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
        >
          <Alert
            onClose={handleCloseSnackbar}
            severity={snackbar.severity}
            sx={{ width: '100%' }}
          >
            {snackbar.message}
          </Alert>
        </Snackbar>
      </Box>
    </ThemeProvider>
  );
}