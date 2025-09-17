import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Button,
  Divider,
  Paper,
  Grid,
  Chip,
  IconButton,
  Accordion,
  AccordionSummary,
  AccordionDetails,
} from '@mui/material';
import {
  ExpandMore as ExpandMoreIcon,
  Business as BusinessIcon,
  Home as HomeIcon,
  CalendarToday as CalendarIcon,
  LocationOn as LocationIcon,
} from '@mui/icons-material';

export default function PropertyInfoPanel({ property, editMode, onSave, loading }) {
  const [formData, setFormData] = useState({
    name: '',
    address: '',
    biru_age: '',
    build_type_id: '',
    description: '',
    postcode: '',
    ...property
  });
  
  const [expanded, setExpanded] = useState({
    basic: true,
    location: true,
    details: false,
  });
  
  useEffect(() => {
    if (property) {
      setFormData({
        name: property.name || '',
        address: property.address || '',
        biru_age: property.biru_age || '',
        build_type_id: property.build_type_id || '',
        description: property.description || '',
        postcode: property.postcode || '',
        ...property
      });
    }
  }, [property]);
  
  const handleChange = (field) => (event) => {
    setFormData(prev => ({
      ...prev,
      [field]: event.target.value
    }));
  };
  
  const handleSubmit = () => {
    onSave(formData);
  };
  
  const handleAccordionChange = (panel) => (event, isExpanded) => {
    setExpanded(prev => ({
      ...prev,
      [panel]: isExpanded
    }));
  };
  
  const buildTypes = [
    { id: '01010', name: 'マンション' },
    { id: '01020', name: 'アパート' },
    { id: '01025', name: '戸建て' },
    { id: '01030', name: 'その他' },
  ];
  
  return (
    <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* ヘッダー */}
      <Box sx={{ p: 2, borderBottom: '1px solid #ddd', bgcolor: 'grey.50' }}>
        <Typography variant="h6" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <BusinessIcon color="primary" />
          物件情報
        </Typography>
        {editMode && (
          <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
            各項目を編集できます
          </Typography>
        )}
      </Box>
      
      {/* コンテンツ */}
      <Box sx={{ flex: 1, overflow: 'auto', p: 0 }}>
        
        {/* 基本情報 */}
        <Accordion 
          expanded={expanded.basic} 
          onChange={handleAccordionChange('basic')}
          elevation={0}
          sx={{ '&:before': { display: 'none' } }}
        >
          <AccordionSummary expandIcon={<ExpandMoreIcon />}>
            <Typography variant="subtitle1" fontWeight="600">基本情報</Typography>
          </AccordionSummary>
          <AccordionDetails sx={{ pt: 0 }}>
            <Grid container spacing={2}>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="物件名"
                  value={formData.name}
                  onChange={handleChange('name')}
                  disabled={!editMode}
                  variant={editMode ? "outlined" : "filled"}
                  size="small"
                />
              </Grid>
              
              <Grid item xs={12} sm={6}>
                <FormControl fullWidth size="small">
                  <InputLabel>建物種別</InputLabel>
                  <Select
                    value={formData.build_type_id}
                    label="建物種別"
                    onChange={handleChange('build_type_id')}
                    disabled={!editMode}
                    variant={editMode ? "outlined" : "filled"}
                  >
                    {buildTypes.map((type) => (
                      <MenuItem key={type.id} value={type.id}>
                        {type.name}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Grid>
              
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="築年数"
                  type="number"
                  value={formData.biru_age}
                  onChange={handleChange('biru_age')}
                  disabled={!editMode}
                  variant={editMode ? "outlined" : "filled"}
                  size="small"
                  InputProps={{
                    endAdornment: <Typography variant="body2" color="text.secondary">年</Typography>
                  }}
                />
              </Grid>
              
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="説明・備考"
                  multiline
                  rows={3}
                  value={formData.description}
                  onChange={handleChange('description')}
                  disabled={!editMode}
                  variant={editMode ? "outlined" : "filled"}
                  size="small"
                />
              </Grid>
            </Grid>
          </AccordionDetails>
        </Accordion>
        
        {/* 所在地情報 */}
        <Accordion 
          expanded={expanded.location} 
          onChange={handleAccordionChange('location')}
          elevation={0}
          sx={{ '&:before': { display: 'none' } }}
        >
          <AccordionSummary expandIcon={<ExpandMoreIcon />}>
            <Typography variant="subtitle1" fontWeight="600">所在地</Typography>
          </AccordionSummary>
          <AccordionDetails sx={{ pt: 0 }}>
            <Grid container spacing={2}>
              <Grid item xs={12} sm={4}>
                <TextField
                  fullWidth
                  label="郵便番号"
                  value={formData.postcode}
                  onChange={handleChange('postcode')}
                  disabled={!editMode}
                  variant={editMode ? "outlined" : "filled"}
                  size="small"
                  placeholder="000-0000"
                />
              </Grid>
              
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="住所"
                  value={formData.address}
                  onChange={handleChange('address')}
                  disabled={!editMode}
                  variant={editMode ? "outlined" : "filled"}
                  size="small"
                />
              </Grid>
              
              {property.latitude && property.longitude && (
                <Grid item xs={12}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, p: 1, bgcolor: 'grey.50', borderRadius: 1 }}>
                    <LocationIcon color="action" fontSize="small" />
                    <Typography variant="body2" color="text.secondary">
                      緯度: {property.latitude.toFixed(6)}, 経度: {property.longitude.toFixed(6)}
                    </Typography>
                  </Box>
                </Grid>
              )}
            </Grid>
          </AccordionDetails>
        </Accordion>
        
        {/* 詳細情報 */}
        <Accordion 
          expanded={expanded.details} 
          onChange={handleAccordionChange('details')}
          elevation={0}
          sx={{ '&:before': { display: 'none' } }}
        >
          <AccordionSummary expandIcon={<ExpandMoreIcon />}>
            <Typography variant="subtitle1" fontWeight="600">詳細情報</Typography>
          </AccordionSummary>
          <AccordionDetails sx={{ pt: 0 }}>
            <Grid container spacing={2}>
              {property.shop_name && (
                <Grid item xs={12}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Typography variant="body2" color="text.secondary">担当営業所:</Typography>
                    <Chip label={property.shop_name} size="small" color="primary" variant="outlined" />
                  </Box>
                </Grid>
              )}
              
              {property.code && (
                <Grid item xs={12}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Typography variant="body2" color="text.secondary">物件コード:</Typography>
                    <Typography variant="body2" fontFamily="monospace">{property.code}</Typography>
                  </Box>
                </Grid>
              )}
              
              <Grid item xs={12}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <CalendarIcon color="action" fontSize="small" />
                  <Typography variant="body2" color="text.secondary">
                    最終更新: {property.updated_at ? new Date(property.updated_at).toLocaleDateString('ja-JP') : '不明'}
                  </Typography>
                </Box>
              </Grid>
            </Grid>
          </AccordionDetails>
        </Accordion>
        
      </Box>
      
      {/* 保存ボタン */}
      {editMode && (
        <Box sx={{ p: 2, borderTop: '1px solid #ddd', bgcolor: 'grey.50' }}>
          <Button
            fullWidth
            variant="contained"
            onClick={handleSubmit}
            disabled={loading}
            sx={{ mb: 1 }}
          >
            {loading ? '保存中...' : '変更を保存'}
          </Button>
        </Box>
      )}
    </Box>
  );
}