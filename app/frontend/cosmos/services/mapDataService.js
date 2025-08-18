// Rails APIとの通信を管理するサービス

const API_BASE_URL = '/api/v1';

class MapDataService {
  // 物件の地図データを取得
  async getMapData(shopCodes = [], searchConditions = {}) {
    try {
      const params = new URLSearchParams();
      
      if (shopCodes.length > 0) {
        params.append('shop_codes', shopCodes.join(','));
      }
      
      // 検索条件をパラメータに追加
      Object.entries(searchConditions).forEach(([key, value]) => {
        if (value !== null && value !== undefined && value !== '') {
          params.append(`search[${key}]`, value);
        }
      });
      
      const url = `${API_BASE_URL}/properties/map_data?${params.toString()}`;
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      
      if (data.status === 'error') {
        throw new Error(data.message || 'サーバーエラーが発生しました');
      }
      
      return data.data;
    } catch (error) {
      console.error('Map data fetch error:', error);
      throw error;
    }
  }
  
  // 物件検索
  async searchProperties(searchConditions) {
    try {
      const response = await fetch(`${API_BASE_URL}/properties/search`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify(searchConditions)
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      
      if (data.status === 'error') {
        throw new Error(data.message || '検索エラーが発生しました');
      }
      
      return data.data;
    } catch (error) {
      console.error('Property search error:', error);
      throw error;
    }
  }
  
  // レイヤーデータを取得
  async getLayerData(layerType) {
    try {
      const response = await fetch(`${API_BASE_URL}/layers/${layerType}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      
      if (data.status === 'error') {
        throw new Error(data.message || 'レイヤーデータの取得に失敗しました');
      }
      
      return data.data;
    } catch (error) {
      console.error('Layer data fetch error:', error);
      throw error;
    }
  }
  
  // 検索条件をAPIで使用する形式に変換
  convertSearchConditions(conditions) {
    const converted = {};
    
    if (conditions.propertyName) {
      converted.property_name = conditions.propertyName;
    }
    if (conditions.address) {
      converted.address = conditions.address;
    }
    if (conditions.buildingType) {
      converted.building_type = conditions.buildingType;
    }
    if (conditions.managementType) {
      converted.management_type = conditions.managementType;
    }
    if (conditions.minRooms) {
      converted.min_rooms = conditions.minRooms;
    }
    if (conditions.maxRooms) {
      converted.max_rooms = conditions.maxRooms;
    }
    if (conditions.maxVacancyRate) {
      converted.max_vacancy_rate = conditions.maxVacancyRate;
    }
    if (conditions.minAge) {
      converted.min_age = conditions.minAge;
    }
    if (conditions.maxAge) {
      converted.max_age = conditions.maxAge;
    }
    
    return converted;
  }
}

// シングルトンとしてエクスポート
export default new MapDataService();