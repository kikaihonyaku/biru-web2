import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Button,
  IconButton,
  Typography,
  Box,
  CircularProgress
} from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import SearchIcon from '@mui/icons-material/Search';
import ClearAllIcon from '@mui/icons-material/ClearAll';

export default function SearchModal({ isOpen, onClose, onSearch, currentConditions = {}, isLoading = false }) {
  const [searchForm, setSearchForm] = useState({
    propertyName: '',
    address: '',
    buildingType: '',
    managementType: '',
    minRooms: '',
    maxRooms: '',
    maxVacancyRate: '',
    minAge: '',
    maxAge: ''
  });

  // モーダルが開かれた時に現在の条件を設定
  useEffect(() => {
    if (isOpen) {
      setSearchForm({
        propertyName: currentConditions.propertyName || '',
        address: currentConditions.address || '',
        buildingType: currentConditions.buildingType || '',
        managementType: currentConditions.managementType || '',
        minRooms: currentConditions.minRooms || '',
        maxRooms: currentConditions.maxRooms || '',
        maxVacancyRate: currentConditions.maxVacancyRate || '',
        minAge: currentConditions.minAge || '',
        maxAge: currentConditions.maxAge || ''
      });
    }
  }, [isOpen, currentConditions]);

  const handleInputChange = (field, value) => {
    setSearchForm(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleSearch = (e) => {
    e.preventDefault();
    onSearch(searchForm);
    onClose();
  };

  const handleReset = () => {
    setSearchForm({
      propertyName: '',
      address: '',
      buildingType: '',
      managementType: '',
      minRooms: '',
      maxRooms: '',
      maxVacancyRate: '',
      minAge: '',
      maxAge: ''
    });
    onSearch({});
  };

  // ESCキーでモーダルを閉じる
  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('keydown', handleEscape);
      document.body.style.overflow = 'unset';
    };
  }, [isOpen, onClose]);

  return (
    <Dialog
      open={isOpen}
      onClose={onClose}
      maxWidth="md"
      fullWidth
      PaperProps={{
        sx: {
          borderRadius: 3,
          maxHeight: '90vh'
        }
      }}
    >
      <DialogTitle
        sx={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          backgroundColor: 'primary.main',
          color: 'white',
          m: 0,
          px: 2,
          py: 0.5,
          minHeight: '40px'
        }}
      >
        <Typography variant="h6" component="div" sx={{ fontWeight: 600 }}>
          検索条件設定
        </Typography>
        <IconButton
          onClick={onClose}
          sx={{
            color: 'white',
            '&:hover': {
              backgroundColor: 'rgba(255, 255, 255, 0.1)'
            }
          }}
        >
          <CloseIcon />
        </IconButton>
      </DialogTitle>

      <Box component="form" onSubmit={handleSearch}>
        <DialogContent sx={{ p: 3 }}>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
            {/* 基本情報セクション */}
            <Box>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 2, color: 'primary.main' }}>
                基本情報
              </Typography>
              <Box sx={{ 
                display: 'flex', 
                flexDirection: 'column',
                gap: 2,
                '@media (min-width: 600px)': {
                  display: 'grid',
                  gridTemplateColumns: 'repeat(2, 1fr)',
                  gap: 2
                }
              }}>
                <TextField
                  fullWidth
                  label="物件名"
                  placeholder="物件名を入力"
                  value={searchForm.propertyName}
                  onChange={(e) => handleInputChange('propertyName', e.target.value)}
                  variant="outlined"
                  size="small"
                />
                <TextField
                  fullWidth
                  label="住所"
                  placeholder="住所を入力"
                  value={searchForm.address}
                  onChange={(e) => handleInputChange('address', e.target.value)}
                  variant="outlined"
                  size="small"
                />
                <FormControl fullWidth size="small">
                  <InputLabel>建物種別</InputLabel>
                  <Select
                    value={searchForm.buildingType}
                    onChange={(e) => handleInputChange('buildingType', e.target.value)}
                    label="建物種別"
                  >
                    <MenuItem value="">選択してください</MenuItem>
                    <MenuItem value="apartment">アパート</MenuItem>
                    <MenuItem value="mansion">マンション</MenuItem>
                    <MenuItem value="house">戸建て</MenuItem>
                    <MenuItem value="other">その他</MenuItem>
                  </Select>
                </FormControl>
                <FormControl fullWidth size="small">
                  <InputLabel>管理方式</InputLabel>
                  <Select
                    value={searchForm.managementType}
                    onChange={(e) => handleInputChange('managementType', e.target.value)}
                    label="管理方式"
                  >
                    <MenuItem value="">選択してください</MenuItem>
                    <MenuItem value="full">一括管理</MenuItem>
                    <MenuItem value="partial">一部管理</MenuItem>
                    <MenuItem value="none">管理なし</MenuItem>
                  </Select>
                </FormControl>
              </Box>
            </Box>

            {/* 戸数条件セクション */}
            <Box>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 2, color: 'primary.main' }}>
                戸数条件
              </Typography>
              <Box sx={{ 
                display: 'flex', 
                flexDirection: 'column',
                gap: 2,
                '@media (min-width: 600px)': {
                  display: 'grid',
                  gridTemplateColumns: 'repeat(2, 1fr)',
                  gap: 2
                }
              }}>
                <TextField
                  fullWidth
                  type="number"
                  label="最小戸数"
                  placeholder="例: 10"
                  InputProps={{ inputProps: { min: 1 } }}
                  value={searchForm.minRooms}
                  onChange={(e) => handleInputChange('minRooms', e.target.value)}
                  variant="outlined"
                  size="small"
                />
                <TextField
                  fullWidth
                  type="number"
                  label="最大戸数"
                  placeholder="例: 50"
                  InputProps={{ inputProps: { min: 1 } }}
                  value={searchForm.maxRooms}
                  onChange={(e) => handleInputChange('maxRooms', e.target.value)}
                  variant="outlined"
                  size="small"
                />
                <TextField
                  fullWidth
                  type="number"
                  label="最大空室率（%）"
                  placeholder="例: 15"
                  InputProps={{ inputProps: { min: 0, max: 100 } }}
                  value={searchForm.maxVacancyRate}
                  onChange={(e) => handleInputChange('maxVacancyRate', e.target.value)}
                  variant="outlined"
                  size="small"
                  sx={{ '@media (min-width: 600px)': { gridColumn: '1 / 2' } }}
                />
              </Box>
            </Box>

            {/* 築年数条件セクション */}
            <Box>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 2, color: 'primary.main' }}>
                築年数条件
              </Typography>
              <Box sx={{ 
                display: 'flex', 
                flexDirection: 'column',
                gap: 2,
                '@media (min-width: 600px)': {
                  display: 'grid',
                  gridTemplateColumns: 'repeat(2, 1fr)',
                  gap: 2
                }
              }}>
                <TextField
                  fullWidth
                  type="number"
                  label="最小築年数（年）"
                  placeholder="例: 5"
                  InputProps={{ inputProps: { min: 0 } }}
                  value={searchForm.minAge}
                  onChange={(e) => handleInputChange('minAge', e.target.value)}
                  variant="outlined"
                  size="small"
                />
                <TextField
                  fullWidth
                  type="number"
                  label="最大築年数（年）"
                  placeholder="例: 25"
                  InputProps={{ inputProps: { min: 0 } }}
                  value={searchForm.maxAge}
                  onChange={(e) => handleInputChange('maxAge', e.target.value)}
                  variant="outlined"
                  size="small"
                />
              </Box>
            </Box>
          </Box>
        </DialogContent>

        <DialogActions sx={{ p: 3, pt: 1, gap: 1 }}>
          <Button
            onClick={handleReset}
            variant="outlined"
            startIcon={<ClearAllIcon />}
            sx={{
              minWidth: 120,
              borderColor: 'grey.300',
              color: 'text.secondary',
              '&:hover': {
                borderColor: 'grey.400',
                backgroundColor: 'grey.50'
              }
            }}
          >
            条件をクリア
          </Button>
          <Button
            type="submit"
            variant="contained"
            startIcon={isLoading ? <CircularProgress size={16} color="inherit" /> : <SearchIcon />}
            disabled={isLoading}
            sx={{
              minWidth: 120,
              boxShadow: 'none',
              '&:hover': {
                boxShadow: 2
              }
            }}
          >
            {isLoading ? '検索中...' : '検索実行'}
          </Button>
        </DialogActions>
      </Box>
    </Dialog>
  );
}