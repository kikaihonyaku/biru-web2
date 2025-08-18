import React, { useEffect, useState } from 'react';
import { useGoogleMaps } from '../../hooks/useGoogleMaps';
import styles from '../../styles/MapSystem.module.css';

export default function MapContainer({ onMarkerSelect, selectedLayers = [] }) {
  const [properties, setProperties] = useState([]);
  const { 
    map, 
    isLoaded, 
    error, 
    addMarker, 
    clearMarkers, 
    showInfoWindow,
    panToLocation,
    fitBounds
  } = useGoogleMaps('google-map', {
    center: { lat: 35.8617, lng: 139.6455 }, // さいたま市周辺
    zoom: 10,
    mapTypeId: 'roadmap'
  });

  // サンプルデータ（後でRails APIから取得）
  const sampleProperties = [
    {
      id: 1,
      name: 'サンプル物件A',
      address: 'さいたま市浦和区',
      latitude: 35.8617,
      longitude: 139.6455,
      type: 'apartment',
      rooms: 25,
      vacantRooms: 3
    },
    {
      id: 2,
      name: 'サンプル物件B',
      address: 'さいたま市大宮区',
      latitude: 35.9067,
      longitude: 139.6233,
      type: 'mansion',
      rooms: 45,
      vacantRooms: 7
    },
    {
      id: 3,
      name: 'サンプル物件C',
      address: 'さいたま市南区',
      latitude: 35.8465,
      longitude: 139.6634,
      type: 'house',
      rooms: 8,
      vacantRooms: 2
    }
  ];

  // 物件タイプに応じたアイコンを取得
  const getPropertyIcon = (property) => {
    const vacancyRate = property.vacantRooms / property.rooms;
    
    // 空室率に応じてアイコンの色を決定（Google Maps標準アイコンを使用）
    if (vacancyRate === 0) {
      return 'http://maps.google.com/mapfiles/ms/icons/blue-dot.png'; // 満室 - 青
    } else if (vacancyRate <= 0.3) {
      return 'http://maps.google.com/mapfiles/ms/icons/green-dot.png'; // 低空室率 - 緑
    } else if (vacancyRate <= 0.6) {
      return 'http://maps.google.com/mapfiles/ms/icons/yellow-dot.png'; // 中空室率 - 黄
    } else if (vacancyRate <= 0.9) {
      return 'http://maps.google.com/mapfiles/ms/icons/orange-dot.png'; // 高空室率 - オレンジ
    } else {
      return 'http://maps.google.com/mapfiles/ms/icons/red-dot.png'; // 満空室 - 赤
    }
  };

  // Railsアセットを使用する場合の代替関数（将来的に使用可能）
  const getRailsAssetIcon = (property) => {
    const vacancyRate = property.vacantRooms / property.rooms;
    
    // Rails asset pipeline経由でアクセスする場合のパス
    if (vacancyRate === 0) {
      return '/assets/marker_blue.png';
    } else if (vacancyRate <= 0.3) {
      return '/assets/marker_green.png';
    } else if (vacancyRate <= 0.6) {
      return '/assets/marker_yellow.png';
    } else if (vacancyRate <= 0.9) {
      return '/assets/marker_orange.png';
    } else {
      return '/assets/marker_red.png';
    }
  };

  // InfoWindow用のHTMLコンテンツを生成
  const createInfoWindowContent = (property) => {
    const vacancyRate = ((property.vacantRooms / property.rooms) * 100).toFixed(1);
    
    return `
      <div style="padding: 10px; min-width: 200px;">
        <h3 style="margin: 0 0 10px 0; color: #333;">${property.name}</h3>
        <p style="margin: 5px 0; color: #666;">${property.address}</p>
        <div style="margin: 10px 0;">
          <div>総戸数: ${property.rooms}戸</div>
          <div>空室数: ${property.vacantRooms}戸</div>
          <div>空室率: ${vacancyRate}%</div>
        </div>
        <div style="margin-top: 15px;">
          <button onclick="window.selectProperty(${property.id})" 
                  style="background: #667eea; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">
            詳細を表示
          </button>
        </div>
      </div>
    `;
  };

  // 地図が読み込まれたら物件マーカーを配置
  useEffect(() => {
    if (isLoaded && map) {
      setProperties(sampleProperties);
      
      // グローバル関数として物件選択関数を設定
      window.selectProperty = (propertyId) => {
        const property = sampleProperties.find(p => p.id === propertyId);
        if (property && onMarkerSelect) {
          onMarkerSelect('property', property);
        }
      };

      // 既存のマーカーをクリア
      clearMarkers();

      // 各物件にマーカーを配置
      sampleProperties.forEach(property => {
        const iconUrl = getPropertyIcon(property);
        console.log(`Creating marker for ${property.name} with icon: ${iconUrl}`);
        
        const marker = addMarker(property.id, {
          position: { lat: property.latitude, lng: property.longitude },
          title: property.name,
          icon: iconUrl, // シンプルな文字列として渡す
          onClick: (marker, id) => {
            const content = createInfoWindowContent(property);
            showInfoWindow(content, marker);
            
            // 地図の中心を移動
            panToLocation({ lat: property.latitude, lng: property.longitude }, 15);
          }
        });
      });

      // 全ての物件が見えるように地図をフィット
      const positions = sampleProperties.map(p => ({ lat: p.latitude, lng: p.longitude }));
      if (positions.length > 0) {
        fitBounds(positions);
      }
    }

    return () => {
      if (window.selectProperty) {
        delete window.selectProperty;
      }
    };
  }, [isLoaded, map]);

  return (
    <div className={styles.mapContainer}>
      {/* 常にmap要素を配置し、状態に応じてオーバーレイを表示 */}
      <div className={styles.mapCanvas} id="google-map">
        {/* Google Maps will be rendered here */}
      </div>
      
      {/* エラー時のオーバーレイ */}
      {error && (
        <div className={styles.mapOverlay}>
          <div className={styles.errorMessage}>
            <h3>地図の読み込みエラー</h3>
            <p>{error}</p>
            <p>Google Maps APIキーの設定を確認してください。</p>
          </div>
        </div>
      )}

      {/* ローディング時のオーバーレイ */}
      {!isLoaded && !error && (
        <div className={styles.mapOverlay}>
          <div className={styles.loadingMessage}>
            <div className={styles.spinner}></div>
            <p>地図を読み込み中...</p>
          </div>
        </div>
      )}
      
      {/* 地図上の操作ボタン */}
      <div className={styles.mapControls}>
        <button 
          className={styles.controlButton}
          onClick={() => {
            const positions = properties.map(p => ({ lat: p.latitude, lng: p.longitude }));
            if (positions.length > 0) {
              fitBounds(positions);
            }
          }}
          title="全体表示"
        >
          🏠 全体表示
        </button>
        
        <button 
          className={styles.controlButton}
          onClick={() => panToLocation({ lat: 35.8617, lng: 139.6455 }, 10)}
          title="初期位置に戻る"
        >
          📍 初期位置
        </button>
      </div>
    </div>
  );
}