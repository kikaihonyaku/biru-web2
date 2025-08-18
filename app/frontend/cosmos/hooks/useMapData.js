import { useState, useEffect } from 'react';
import mapDataService from '../services/mapDataService';

export function useMapData() {
  const [properties, setProperties] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const [searchConditions, setSearchConditions] = useState({});

  // 物件データを取得する関数
  const fetchProperties = async (shopCodes = [], conditions = {}) => {
    setIsLoading(true);
    setError(null);
    
    try {
      const convertedConditions = mapDataService.convertSearchConditions(conditions);
      const data = await mapDataService.getMapData(shopCodes, convertedConditions);
      setProperties(data.buildings || []);
      setSearchConditions(conditions);
    } catch (err) {
      setError(err.message);
      console.error('Failed to fetch properties:', err);
    } finally {
      setIsLoading(false);
    }
  };

  // 検索実行関数
  const searchProperties = async (conditions) => {
    await fetchProperties([], conditions);
  };

  // レイヤーデータ取得関数
  const fetchLayerData = async (layerType) => {
    try {
      const data = await mapDataService.getLayerData(layerType);
      return data;
    } catch (err) {
      console.error(`Failed to fetch layer data for ${layerType}:`, err);
      throw err;
    }
  };

  // 初期データの取得
  useEffect(() => {
    fetchProperties();
  }, []);

  return {
    properties,
    isLoading,
    error,
    searchConditions,
    fetchProperties,
    searchProperties,
    fetchLayerData
  };
}