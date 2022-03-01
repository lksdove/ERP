using com.whhercp.appbase.remoting;
using com.whhercp.dataobject;
using DevExpress.Xpf.Charts;
using DevExpress.Xpf.Grid;
using System;
using System.Collections;
using System.Windows;
using Wahaha.Collector;
using Wahaha.OOSClient;
using WhhControl.pages;
using Whhim.Mes.Utils;
using WhhLib.src.com.whhercp.appbase.remoting;

namespace Whhim.Mes.business.basedata
{
    /// <summary>
    /// test.xaml 的交互逻辑
    /// </summary>
    public partial class test : BasePage
    {
        private IWhhRemoteObject whhhRemoteObject;
        private IWhhDataStoreService service = null;
        private OOSClient ooSClient;
        private WahahaCollector collector = new WahahaCollector(typeof(test));
        public test()
        {
            InitializeComponent();
            ooSClient = new OOSClient();
            // 初始化service
            whhhRemoteObject = this.GreateWindowRemotingService("usebean_mesWorkClassService");
            service = this.GreateWindowDSService("usebean_mesBaseDataService");
            this.grid.InitGrid("dw_test_mdm_supplier_apply", service, "ds_test_mdm_supplier_apply");
            collector.dwCollect("dw_test_mdm_supplier_apply");

            //this.date.labDateName.Content = "起止日期";
            //this.date.labDateName.Visibility = Visibility.Hidden;
            //this.date.labDateName.Width = 0;

            //固定几列不动
            fixedColumn(4);

            this.box.Items.Add("是否选中");
        }

       

        /// <summary>
        /// 新增一行
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void addBtn_Click(object sender, RoutedEventArgs e)
        {
            GridColumnCollection columnCollection = this.grid.Columns;
            //this.grid.CollapseGroupRow;
            //this.grid.ExpandGroupRow;
            columnCollection[5].Visible = false;
            columnCollection[6].Visible = false;
            MessageBox.Show("1");
        }

        /// <summary>
        /// 固定列在最左边不可拖拉
        /// </summary>
        /// <param name="n">列数</param>
        private void fixedColumn(int n)
        {
            GridColumnCollection columnCollection = this.grid.Columns;
            for (int i = 0; i < n; i++)
            {
                columnCollection[i].Fixed = FixedStyle.Left;
            }
        }

        //复选框测试
        private void boxBtn_Click(object sender, RoutedEventArgs e)
        {

        }

        private void box_SelectedIndexChanged(object sender, RoutedEventArgs e)
        {
            int i = this.box.SelectedIndex;// 0 选中 -1 未选中
            MessageBox.Show(i.ToString());
        }
    }
}
