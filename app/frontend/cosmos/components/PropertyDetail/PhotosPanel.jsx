import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Button,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Grid,
  Card,
  CardMedia,
  CardActions,
  Tooltip,
  CircularProgress,
  Alert,
  Fab,
  Chip,
} from '@mui/material';
import {
  PhotoLibrary as PhotoLibraryIcon,
  Add as AddIcon,
  Delete as DeleteIcon,
  Fullscreen as FullscreenIcon,
  CloudUpload as CloudUploadIcon,
  Close as CloseIcon,
  ZoomIn as ZoomInIcon,
} from '@mui/icons-material';

export default function PhotosPanel({ propertyId, editMode, onPhotosUpdate }) {
  const [photos, setPhotos] = useState([]);
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [uploadDialogOpen, setUploadDialogOpen] = useState(false);
  const [previewDialogOpen, setPreviewDialogOpen] = useState(false);
  const [selectedPhoto, setSelectedPhoto] = useState(null);
  const [dragActive, setDragActive] = useState(false);
  
  // 写真データ取得
  useEffect(() => {
    fetchPhotos();
  }, [propertyId]);
  
  const fetchPhotos = async () => {
    try {
      setLoading(true);
      const response = await fetch(`/api/v1/properties/${propertyId}/photos`);
      if (response.ok) {
        const data = await response.json();
        setPhotos(data.data || []);
      }
    } catch (error) {
      console.error('写真データの取得に失敗:', error);
    } finally {
      setLoading(false);
    }
  };
  
  const handleFileUpload = async (files) => {
    if (!files || files.length === 0) return;
    
    try {
      setUploading(true);
      
      for (const file of files) {
        if (!file.type.startsWith('image/')) {
          alert('画像ファイルのみアップロード可能です');
          continue;
        }
        
        const formData = new FormData();
        formData.append('photo', file);
        formData.append('property_id', propertyId);
        
        const response = await fetch(`/api/v1/properties/${propertyId}/photos`, {
          method: 'POST',
          body: formData,
        });
        
        if (!response.ok) {
          throw new Error(`ファイル ${file.name} のアップロードに失敗しました`);
        }
      }
      
      await fetchPhotos();
      setUploadDialogOpen(false);
      onPhotosUpdate();
      
    } catch (error) {
      console.error('写真アップロードエラー:', error);
      alert(error.message);
    } finally {
      setUploading(false);
    }
  };
  
  const handleDeletePhoto = async (photoId) => {
    if (!confirm('この写真を削除してもよろしいですか？')) return;
    
    try {
      const response = await fetch(`/api/v1/properties/${propertyId}/photos/${photoId}`, {
        method: 'DELETE',
      });
      
      if (!response.ok) {
        throw new Error('写真の削除に失敗しました');
      }
      
      await fetchPhotos();
      onPhotosUpdate();
      
    } catch (error) {
      console.error('写真削除エラー:', error);
      alert(error.message);
    }
  };
  
  const handleDrag = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === 'dragenter' || e.type === 'dragover') {
      setDragActive(true);
    } else if (e.type === 'dragleave') {
      setDragActive(false);
    }
  };
  
  const handleDrop = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      handleFileUpload(Array.from(e.dataTransfer.files));
    }
  };
  
  const handleFileSelect = (e) => {
    if (e.target.files && e.target.files[0]) {
      handleFileUpload(Array.from(e.target.files));
    }
  };
  
  const openPreview = (photo) => {
    setSelectedPhoto(photo);
    setPreviewDialogOpen(true);
  };
  
  return (
    <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* ヘッダー */}
      <Box sx={{ p: 2, borderBottom: '1px solid #ddd', bgcolor: 'grey.50' }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="h6" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <PhotoLibraryIcon color="primary" />
            外観写真 ({photos.length})
          </Typography>
          
          {editMode && (
            <Button
              variant="contained"
              size="small"
              startIcon={<AddIcon />}
              onClick={() => setUploadDialogOpen(true)}
            >
              写真追加
            </Button>
          )}
        </Box>
      </Box>
      
      {/* 写真一覧 */}
      <Box sx={{ flex: 1, overflow: 'auto', p: 1 }}>
        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
            <CircularProgress />
          </Box>
        ) : photos.length === 0 ? (
          <Box sx={{ 
            display: 'flex', 
            flexDirection: 'column',
            justifyContent: 'center', 
            alignItems: 'center', 
            height: '100%',
            textAlign: 'center',
            p: 2
          }}>
            <PhotoLibraryIcon sx={{ fontSize: 48, color: 'text.secondary', mb: 2 }} />
            <Typography color="text.secondary" gutterBottom>
              写真が登録されていません
            </Typography>
            {editMode && (
              <Button
                variant="outlined"
                startIcon={<AddIcon />}
                onClick={() => setUploadDialogOpen(true)}
                sx={{ mt: 1 }}
              >
                写真を追加
              </Button>
            )}
          </Box>
        ) : (
          <Grid container spacing={1}>
            {photos.map((photo, index) => (
              <Grid item xs={6} sm={4} md={3} key={photo.id}>
                <Card sx={{ position: 'relative' }}>
                  <CardMedia
                    component="img"
                    height="120"
                    image={photo.thumbnail_url || photo.url}
                    alt={`外観写真 ${index + 1}`}
                    sx={{ 
                      cursor: 'pointer',
                      objectFit: 'cover',
                    }}
                    onClick={() => openPreview(photo)}
                  />
                  
                  {/* 写真のオーバーレイ */}
                  <Box sx={{
                    position: 'absolute',
                    top: 0,
                    right: 0,
                    display: 'flex',
                    gap: 0.5,
                    p: 0.5,
                  }}>
                    <Tooltip title="拡大表示">
                      <IconButton
                        size="small"
                        onClick={() => openPreview(photo)}
                        sx={{ 
                          bgcolor: 'rgba(0,0,0,0.6)', 
                          color: 'white',
                          '&:hover': { bgcolor: 'rgba(0,0,0,0.8)' }
                        }}
                      >
                        <ZoomInIcon fontSize="small" />
                      </IconButton>
                    </Tooltip>
                    
                    {editMode && (
                      <Tooltip title="削除">
                        <IconButton
                          size="small"
                          onClick={() => handleDeletePhoto(photo.id)}
                          sx={{ 
                            bgcolor: 'rgba(255,0,0,0.6)', 
                            color: 'white',
                            '&:hover': { bgcolor: 'rgba(255,0,0,0.8)' }
                          }}
                        >
                          <DeleteIcon fontSize="small" />
                        </IconButton>
                      </Tooltip>
                    )}
                  </Box>
                  
                  {/* メイン写真マーク */}
                  {index === 0 && (
                    <Box sx={{
                      position: 'absolute',
                      bottom: 4,
                      left: 4,
                    }}>
                      <Chip
                        label="メイン"
                        size="small"
                        color="primary"
                        sx={{ 
                          height: 20,
                          fontSize: '0.7rem',
                          bgcolor: 'rgba(25, 118, 210, 0.9)',
                          color: 'white'
                        }}
                      />
                    </Box>
                  )}
                </Card>
              </Grid>
            ))}
          </Grid>
        )}
      </Box>
      
      {/* アップロードダイアログ */}
      <Dialog
        open={uploadDialogOpen}
        onClose={() => setUploadDialogOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>写真アップロード</DialogTitle>
        <DialogContent>
          <Box
            sx={{
              border: '2px dashed',
              borderColor: dragActive ? 'primary.main' : 'grey.300',
              borderRadius: 2,
              p: 4,
              textAlign: 'center',
              bgcolor: dragActive ? 'primary.50' : 'transparent',
              transition: 'all 0.2s ease',
              cursor: 'pointer',
              '&:hover': {
                borderColor: 'primary.main',
                bgcolor: 'grey.50',
              }
            }}
            onDragEnter={handleDrag}
            onDragLeave={handleDrag}
            onDragOver={handleDrag}
            onDrop={handleDrop}
            onClick={() => document.getElementById('photo-upload-input').click()}
          >
            <CloudUploadIcon sx={{ fontSize: 48, color: 'text.secondary', mb: 2 }} />
            <Typography variant="h6" gutterBottom>
              写真をドラッグ&ドロップ
            </Typography>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              またはクリックしてファイルを選択
            </Typography>
            <Typography variant="caption" color="text.secondary">
              JPG, PNG, GIF形式をサポート
            </Typography>
            
            <input
              id="photo-upload-input"
              type="file"
              accept="image/*"
              multiple
              style={{ display: 'none' }}
              onChange={handleFileSelect}
            />
          </Box>
          
          {uploading && (
            <Box sx={{ display: 'flex', justifyContent: 'center', mt: 2 }}>
              <CircularProgress />
              <Typography sx={{ ml: 2 }}>アップロード中...</Typography>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setUploadDialogOpen(false)} disabled={uploading}>
            キャンセル
          </Button>
        </DialogActions>
      </Dialog>
      
      {/* 写真プレビューダイアログ */}
      <Dialog
        open={previewDialogOpen}
        onClose={() => setPreviewDialogOpen(false)}
        maxWidth="lg"
        fullWidth
      >
        <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="h6">写真プレビュー</Typography>
          <IconButton onClick={() => setPreviewDialogOpen(false)}>
            <CloseIcon />
          </IconButton>
        </DialogTitle>
        <DialogContent sx={{ p: 0 }}>
          {selectedPhoto && (
            <Box sx={{ textAlign: 'center', bgcolor: 'black' }}>
              <img
                src={selectedPhoto.url}
                alt="写真プレビュー"
                style={{
                  maxWidth: '100%',
                  maxHeight: '70vh',
                  objectFit: 'contain',
                }}
              />
            </Box>
          )}
        </DialogContent>
      </Dialog>
      
      {/* フローティングアクションボタン（小画面用） */}
      {editMode && photos.length > 0 && (
        <Fab
          color="primary"
          size="small"
          onClick={() => setUploadDialogOpen(true)}
          sx={{
            position: 'absolute',
            bottom: 16,
            right: 16,
          }}
        >
          <AddIcon />
        </Fab>
      )}
    </Box>
  );
}