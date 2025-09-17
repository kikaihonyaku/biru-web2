import React, { useState, useEffect, useRef } from 'react';
import {
  Box,
  Typography,
  Paper,
  IconButton,
  Tooltip,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  CircularProgress,
} from '@mui/material';
import {
  MyLocation as MyLocationIcon,
  ZoomIn as ZoomInIcon,
  ZoomOut as ZoomOutIcon,
  Fullscreen as FullscreenIcon,
  Edit as EditIcon,
  Check as CheckIcon,
  Close as CloseIcon,
} from '@mui/icons-material';

export default function PropertyMapPanel({ property, onLocationUpdate }) {
  const mapRef = useRef(null);
  const mapInstanceRef = useRef(null);
  const markerRef = useRef(null);
  const [mapLoaded, setMapLoaded] = useState(false);
  const [loading, setLoading] = useState(true);
  const [editingLocation, setEditingLocation] = useState(false);
  const [addressSearchOpen, setAddressSearchOpen] = useState(false);
  const [searchAddress, setSearchAddress] = useState('');
  const [searchLoading, setSearchLoading] = useState(false);
  
  // Google Maps初期化
  useEffect(() => {
    if (!window.google) {
      loadGoogleMaps();
    } else {
      initializeMap();
    }
  }, []);
  
  // 物件情報が更新された時にマーカーを更新
  useEffect(() => {
    if (mapInstanceRef.current && property?.latitude && property?.longitude) {
      updateMarkerPosition(property.latitude, property.longitude);
    }
  }, [property]);
  
  const loadGoogleMaps = () => {
    const script = document.createElement('script');
    script.src = `https://maps.googleapis.com/maps/api/js?key=${process.env.REACT_APP_GOOGLE_MAPS_API_KEY}&libraries=places`;
    script.async = true;
    script.defer = true;
    script.onload = initializeMap;
    script.onerror = () => {
      console.error('Google Maps APIの読み込みに失敗しました');
      setLoading(false);
    };
    document.head.appendChild(script);
  };
  
  const initializeMap = () => {
    try {
      const defaultLat = property?.latitude || 35.6762;
      const defaultLng = property?.longitude || 139.6503;
      
      const map = new window.google.maps.Map(mapRef.current, {
        center: { lat: defaultLat, lng: defaultLng },
        zoom: 16,
        mapTypeId: window.google.maps.MapTypeId.ROADMAP,
        streetViewControl: true,
        fullscreenControl: false,
        zoomControl: false,
        mapTypeControl: true,
        mapTypeControlOptions: {
          style: window.google.maps.MapTypeControlStyle.DROPDOWN_MENU,
          position: window.google.maps.ControlPosition.TOP_RIGHT,
        },
      });
      
      const marker = new window.google.maps.Marker({
        position: { lat: defaultLat, lng: defaultLng },
        map: map,
        title: property?.name || '物件',
        draggable: false,
      });
      
      // 情報ウィンドウ
      const infoWindow = new window.google.maps.InfoWindow({
        content: `
          <div style="padding: 8px;">
            <h4 style="margin: 0 0 4px 0; color: #1976d2;">${property?.name || '物件'}</h4>
            <p style="margin: 0; font-size: 14px; color: #666;">${property?.address || ''}</p>
          </div>
        `,
      });
      
      marker.addListener('click', () => {
        infoWindow.open(map, marker);
      });
      
      mapInstanceRef.current = map;
      markerRef.current = marker;
      setMapLoaded(true);
      setLoading(false);
      
    } catch (error) {
      console.error('地図の初期化に失敗しました:', error);
      setLoading(false);
    }
  };
  
  const updateMarkerPosition = (lat, lng) => {
    if (markerRef.current && mapInstanceRef.current) {
      const position = { lat, lng };
      markerRef.current.setPosition(position);
      mapInstanceRef.current.setCenter(position);
    }
  };
  
  const handleLocationEdit = () => {
    if (!editingLocation) {
      setEditingLocation(true);
      if (markerRef.current) {
        markerRef.current.setDraggable(true);
        
        markerRef.current.addListener('dragend', (event) => {
          const lat = event.latLng.lat();
          const lng = event.latLng.lng();
          onLocationUpdate(lat, lng);
        });
      }
    } else {
      setEditingLocation(false);
      if (markerRef.current) {
        markerRef.current.setDraggable(false);
      }
    }
  };
  
  const handleZoomIn = () => {
    if (mapInstanceRef.current) {
      const currentZoom = mapInstanceRef.current.getZoom();
      mapInstanceRef.current.setZoom(currentZoom + 1);
    }
  };
  
  const handleZoomOut = () => {
    if (mapInstanceRef.current) {
      const currentZoom = mapInstanceRef.current.getZoom();
      mapInstanceRef.current.setZoom(currentZoom - 1);
    }
  };
  
  const handleMyLocation = () => {
    if (navigator.geolocation && mapInstanceRef.current) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          const lng = position.coords.longitude;
          mapInstanceRef.current.setCenter({ lat, lng });
          mapInstanceRef.current.setZoom(16);
        },
        (error) => {
          console.error('現在地の取得に失敗しました:', error);
        }
      );
    }
  };
  
  const handleAddressSearch = async () => {
    if (!searchAddress.trim()) return;
    
    try {
      setSearchLoading(true);
      const geocoder = new window.google.maps.Geocoder();
      
      geocoder.geocode({ address: searchAddress }, (results, status) => {
        setSearchLoading(false);
        
        if (status === 'OK' && results[0]) {
          const location = results[0].geometry.location;
          const lat = location.lat();
          const lng = location.lng();
          
          updateMarkerPosition(lat, lng);
          onLocationUpdate(lat, lng);
          setAddressSearchOpen(false);
          setSearchAddress('');
        } else {
          alert('住所が見つかりませんでした');
        }
      });
    } catch (error) {
      setSearchLoading(false);
      console.error('住所検索に失敗しました:', error);
    }
  };
  
  const handleFullscreen = () => {
    if (mapRef.current) {
      if (mapRef.current.requestFullscreen) {
        mapRef.current.requestFullscreen();
      }
    }
  };
  
  return (
    <Box sx={{ height: '100%', position: 'relative' }}>
      {/* 地図ヘッダー */}
      <Box sx={{ 
        position: 'absolute', 
        top: 0, 
        left: 0, 
        right: 0, 
        zIndex: 1,
        p: 1,
        bgcolor: 'rgba(255, 255, 255, 0.95)',
        borderBottom: '1px solid #ddd'
      }}>
        <Typography variant="subtitle1" fontWeight="600">
          物件位置
        </Typography>
        {property?.address && (
          <Typography variant="body2" color="text.secondary">
            {property.address}
          </Typography>
        )}
      </Box>
      
      {/* 地図コンテナ */}
      <Box
        ref={mapRef}
        sx={{
          width: '100%',
          height: '100%',
          bgcolor: 'grey.100',
          pt: '60px', // ヘッダーの高さ分
        }}
      />
      
      {/* ローディング */}
      {loading && (
        <Box sx={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          zIndex: 2,
        }}>
          <CircularProgress />
        </Box>
      )}
      
      {/* 地図コントロール */}
      {mapLoaded && (
        <Box sx={{
          position: 'absolute',
          top: 80,
          right: 16,
          display: 'flex',
          flexDirection: 'column',
          gap: 1,
          zIndex: 1,
        }}>
          <Tooltip title="ズームイン">
            <IconButton
              size="small"
              onClick={handleZoomIn}
              sx={{ bgcolor: 'white', boxShadow: 2 }}
            >
              <ZoomInIcon />
            </IconButton>
          </Tooltip>
          
          <Tooltip title="ズームアウト">
            <IconButton
              size="small"
              onClick={handleZoomOut}
              sx={{ bgcolor: 'white', boxShadow: 2 }}
            >
              <ZoomOutIcon />
            </IconButton>
          </Tooltip>
          
          <Tooltip title="現在地">
            <IconButton
              size="small"
              onClick={handleMyLocation}
              sx={{ bgcolor: 'white', boxShadow: 2 }}
            >
              <MyLocationIcon />
            </IconButton>
          </Tooltip>
          
          <Tooltip title="フルスクリーン">
            <IconButton
              size="small"
              onClick={handleFullscreen}
              sx={{ bgcolor: 'white', boxShadow: 2 }}
            >
              <FullscreenIcon />
            </IconButton>
          </Tooltip>
        </Box>
      )}
      
      {/* 位置編集コントロール */}
      {mapLoaded && (
        <Box sx={{
          position: 'absolute',
          bottom: 16,
          left: 16,
          display: 'flex',
          gap: 1,
          zIndex: 1,
        }}>
          <Button
            variant="contained"
            size="small"
            startIcon={editingLocation ? <CheckIcon /> : <EditIcon />}
            onClick={handleLocationEdit}
            color={editingLocation ? "success" : "primary"}
          >
            {editingLocation ? '完了' : '位置編集'}
          </Button>
          
          <Button
            variant="outlined"
            size="small"
            onClick={() => setAddressSearchOpen(true)}
            sx={{ bgcolor: 'white' }}
          >
            住所検索
          </Button>
        </Box>
      )}
      
      {/* 住所検索ダイアログ */}
      <Dialog 
        open={addressSearchOpen} 
        onClose={() => setAddressSearchOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>住所検索</DialogTitle>
        <DialogContent>
          <TextField
            fullWidth
            label="住所を入力"
            value={searchAddress}
            onChange={(e) => setSearchAddress(e.target.value)}
            onKeyPress={(e) => {
              if (e.key === 'Enter') {
                handleAddressSearch();
              }
            }}
            placeholder="例: 東京都千代田区丸の内1-1-1"
            sx={{ mt: 1 }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setAddressSearchOpen(false)}>
            キャンセル
          </Button>
          <Button 
            onClick={handleAddressSearch}
            variant="contained"
            disabled={searchLoading || !searchAddress.trim()}
          >
            {searchLoading ? <CircularProgress size={20} /> : '検索'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}