import React, { useState } from 'react';
import {
  Box,
  Typography,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Grid,
  Tooltip,
  Menu,
  MenuItem as MenuItemComponent,
  Alert,
  CircularProgress,
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  MoreVert as MoreVertIcon,
  Home as HomeIcon,
  CheckCircle as CheckCircleIcon,
  Cancel as CancelIcon,
  HourglassEmpty as HourglassEmptyIcon,
} from '@mui/icons-material';

export default function RoomsPanel({ propertyId, rooms, onRoomsUpdate, editMode }) {
  const [roomDialogOpen, setRoomDialogOpen] = useState(false);
  const [editingRoom, setEditingRoom] = useState(null);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [roomToDelete, setRoomToDelete] = useState(null);
  const [menuAnchor, setMenuAnchor] = useState(null);
  const [selectedRoom, setSelectedRoom] = useState(null);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    floor: '',
    room_layout_id: '',
    area: '',
    rent: '',
    management_fee: '',
    deposit: '',
    key_money: '',
    room_status_id: '',
    description: '',
  });
  
  // 部屋ステータスの定義
  const roomStatuses = [
    { id: '1', name: '空室', color: 'success', icon: <CheckCircleIcon /> },
    { id: '2', name: '入居中', color: 'default', icon: <HomeIcon /> },
    { id: '3', name: '入居予定', color: 'warning', icon: <HourglassEmptyIcon /> },
    { id: '4', name: '退去予定', color: 'error', icon: <CancelIcon /> },
  ];
  
  // 間取りの定義
  const roomLayouts = [
    { id: '1', name: '1R' },
    { id: '2', name: '1K' },
    { id: '3', name: '1DK' },
    { id: '4', name: '1LDK' },
    { id: '5', name: '2K' },
    { id: '6', name: '2DK' },
    { id: '7', name: '2LDK' },
    { id: '8', name: '3K' },
    { id: '9', name: '3DK' },
    { id: '10', name: '3LDK' },
    { id: '11', name: '4LDK以上' },
  ];
  
  const handleAddRoom = () => {
    setEditingRoom(null);
    setFormData({
      name: '',
      floor: '',
      room_layout_id: '',
      area: '',
      rent: '',
      management_fee: '',
      deposit: '',
      key_money: '',
      room_status_id: '1',
      description: '',
    });
    setRoomDialogOpen(true);
  };
  
  const handleEditRoom = (room) => {
    setEditingRoom(room);
    setFormData({
      name: room.name || '',
      floor: room.floor || '',
      room_layout_id: room.room_layout_id || '',
      area: room.area || '',
      rent: room.rent || '',
      management_fee: room.management_fee || '',
      deposit: room.deposit || '',
      key_money: room.key_money || '',
      room_status_id: room.room_status_id || '1',
      description: room.description || '',
    });
    setRoomDialogOpen(true);
    handleMenuClose();
  };
  
  const handleDeleteRoom = (room) => {
    setRoomToDelete(room);
    setDeleteConfirmOpen(true);
    handleMenuClose();
  };
  
  const handleSaveRoom = async () => {
    try {
      setLoading(true);
      
      const url = editingRoom
        ? `/api/v1/properties/${propertyId}/rooms/${editingRoom.id}`
        : `/api/v1/properties/${propertyId}/rooms`;
      
      const method = editingRoom ? 'PUT' : 'POST';
      
      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ room: formData }),
      });
      
      if (!response.ok) {
        throw new Error('部屋の保存に失敗しました');
      }
      
      setRoomDialogOpen(false);
      onRoomsUpdate();
      
    } catch (error) {
      console.error('部屋保存エラー:', error);
      alert(error.message);
    } finally {
      setLoading(false);
    }
  };
  
  const handleConfirmDelete = async () => {
    if (!roomToDelete) return;
    
    try {
      setLoading(true);
      
      const response = await fetch(`/api/v1/properties/${propertyId}/rooms/${roomToDelete.id}`, {
        method: 'DELETE',
      });
      
      if (!response.ok) {
        throw new Error('部屋の削除に失敗しました');
      }
      
      setDeleteConfirmOpen(false);
      setRoomToDelete(null);
      onRoomsUpdate();
      
    } catch (error) {
      console.error('部屋削除エラー:', error);
      alert(error.message);
    } finally {
      setLoading(false);
    }
  };
  
  const handleMenuOpen = (event, room) => {
    setMenuAnchor(event.currentTarget);
    setSelectedRoom(room);
  };
  
  const handleMenuClose = () => {
    setMenuAnchor(null);
    setSelectedRoom(null);
  };
  
  const handleChange = (field) => (event) => {
    setFormData(prev => ({
      ...prev,
      [field]: event.target.value
    }));
  };
  
  const getStatusInfo = (statusId) => {
    return roomStatuses.find(status => status.id === statusId) || roomStatuses[0];
  };
  
  const getLayoutName = (layoutId) => {
    const layout = roomLayouts.find(layout => layout.id === layoutId);
    return layout ? layout.name : '-';
  };
  
  const formatCurrency = (amount) => {
    if (!amount) return '-';
    return new Intl.NumberFormat('ja-JP', {
      style: 'currency',
      currency: 'JPY',
    }).format(amount);
  };
  
  return (
    <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* ヘッダー */}
      <Box sx={{ p: 2, borderBottom: '1px solid #ddd', bgcolor: 'grey.50' }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="h6" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <HomeIcon color="primary" />
            部屋一覧 ({rooms.length}室)
          </Typography>
          
          {editMode && (
            <Button
              variant="contained"
              size="small"
              startIcon={<AddIcon />}
              onClick={handleAddRoom}
            >
              部屋追加
            </Button>
          )}
        </Box>
        
        {/* 統計情報 */}
        <Box sx={{ display: 'flex', gap: 1, mt: 1, flexWrap: 'wrap' }}>
          {roomStatuses.map(status => {
            const count = rooms.filter(room => room.room_status_id === status.id).length;
            return count > 0 ? (
              <Chip
                key={status.id}
                label={`${status.name}: ${count}`}
                size="small"
                color={status.color}
                variant="outlined"
              />
            ) : null;
          })}
        </Box>
      </Box>
      
      {/* 部屋一覧テーブル */}
      <Box sx={{ flex: 1, overflow: 'auto' }}>
        {rooms.length === 0 ? (
          <Box sx={{ p: 4, textAlign: 'center' }}>
            <Typography color="text.secondary">
              部屋が登録されていません
            </Typography>
            {editMode && (
              <Button
                variant="outlined"
                startIcon={<AddIcon />}
                onClick={handleAddRoom}
                sx={{ mt: 2 }}
              >
                最初の部屋を追加
              </Button>
            )}
          </Box>
        ) : (
          <TableContainer>
            <Table size="small" stickyHeader>
              <TableHead>
                <TableRow>
                  <TableCell>部屋名</TableCell>
                  <TableCell>階</TableCell>
                  <TableCell>間取り</TableCell>
                  <TableCell align="right">面積</TableCell>
                  <TableCell align="right">賃料</TableCell>
                  <TableCell>状態</TableCell>
                  {editMode && <TableCell align="center">操作</TableCell>}
                </TableRow>
              </TableHead>
              <TableBody>
                {rooms.map((room) => {
                  const statusInfo = getStatusInfo(room.room_status_id);
                  return (
                    <TableRow key={room.id} hover>
                      <TableCell>
                        <Typography variant="body2" fontWeight="500">
                          {room.name}
                        </Typography>
                      </TableCell>
                      <TableCell>{room.floor}F</TableCell>
                      <TableCell>{getLayoutName(room.room_layout_id)}</TableCell>
                      <TableCell align="right">
                        {room.area ? `${room.area}㎡` : '-'}
                      </TableCell>
                      <TableCell align="right">
                        <Typography variant="body2">
                          {formatCurrency(room.rent)}
                        </Typography>
                        {room.management_fee && (
                          <Typography variant="caption" color="text.secondary" display="block">
                            管理費: {formatCurrency(room.management_fee)}
                          </Typography>
                        )}
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={statusInfo.name}
                          size="small"
                          color={statusInfo.color}
                          icon={statusInfo.icon}
                        />
                      </TableCell>
                      {editMode && (
                        <TableCell align="center">
                          <IconButton
                            size="small"
                            onClick={(e) => handleMenuOpen(e, room)}
                          >
                            <MoreVertIcon />
                          </IconButton>
                        </TableCell>
                      )}
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </TableContainer>
        )}
      </Box>
      
      {/* アクションメニュー */}
      <Menu
        anchorEl={menuAnchor}
        open={Boolean(menuAnchor)}
        onClose={handleMenuClose}
      >
        <MenuItemComponent onClick={() => handleEditRoom(selectedRoom)}>
          <EditIcon sx={{ mr: 1 }} fontSize="small" />
          編集
        </MenuItemComponent>
        <MenuItemComponent onClick={() => handleDeleteRoom(selectedRoom)}>
          <DeleteIcon sx={{ mr: 1 }} fontSize="small" />
          削除
        </MenuItemComponent>
      </Menu>
      
      {/* 部屋編集ダイアログ */}
      <Dialog
        open={roomDialogOpen}
        onClose={() => setRoomDialogOpen(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          {editingRoom ? '部屋編集' : '部屋追加'}
        </DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 1 }}>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="部屋名"
                value={formData.name}
                onChange={handleChange('name')}
                required
                size="small"
              />
            </Grid>
            
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="階数"
                type="number"
                value={formData.floor}
                onChange={handleChange('floor')}
                size="small"
              />
            </Grid>
            
            <Grid item xs={12} sm={6}>
              <FormControl fullWidth size="small">
                <InputLabel>間取り</InputLabel>
                <Select
                  value={formData.room_layout_id}
                  label="間取り"
                  onChange={handleChange('room_layout_id')}
                >
                  {roomLayouts.map((layout) => (
                    <MenuItem key={layout.id} value={layout.id}>
                      {layout.name}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="面積 (㎡)"
                type="number"
                value={formData.area}
                onChange={handleChange('area')}
                size="small"
              />
            </Grid>
            
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="賃料"
                type="number"
                value={formData.rent}
                onChange={handleChange('rent')}
                size="small"
              />
            </Grid>
            
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="管理費"
                type="number"
                value={formData.management_fee}
                onChange={handleChange('management_fee')}
                size="small"
              />
            </Grid>
            
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="敷金"
                type="number"
                value={formData.deposit}
                onChange={handleChange('deposit')}
                size="small"
              />
            </Grid>
            
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="礼金"
                type="number"
                value={formData.key_money}
                onChange={handleChange('key_money')}
                size="small"
              />
            </Grid>
            
            <Grid item xs={12}>
              <FormControl fullWidth size="small">
                <InputLabel>状態</InputLabel>
                <Select
                  value={formData.room_status_id}
                  label="状態"
                  onChange={handleChange('room_status_id')}
                >
                  {roomStatuses.map((status) => (
                    <MenuItem key={status.id} value={status.id}>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        {status.icon}
                        {status.name}
                      </Box>
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="備考"
                multiline
                rows={3}
                value={formData.description}
                onChange={handleChange('description')}
                size="small"
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRoomDialogOpen(false)}>
            キャンセル
          </Button>
          <Button 
            onClick={handleSaveRoom}
            variant="contained"
            disabled={loading || !formData.name}
          >
            {loading ? <CircularProgress size={20} /> : '保存'}
          </Button>
        </DialogActions>
      </Dialog>
      
      {/* 削除確認ダイアログ */}
      <Dialog
        open={deleteConfirmOpen}
        onClose={() => setDeleteConfirmOpen(false)}
      >
        <DialogTitle>部屋の削除</DialogTitle>
        <DialogContent>
          <Alert severity="warning" sx={{ mb: 2 }}>
            この操作は取り消せません。
          </Alert>
          <Typography>
            部屋「{roomToDelete?.name}」を削除してもよろしいですか？
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteConfirmOpen(false)}>
            キャンセル
          </Button>
          <Button 
            onClick={handleConfirmDelete}
            variant="contained"
            color="error"
            disabled={loading}
          >
            {loading ? <CircularProgress size={20} /> : '削除'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}