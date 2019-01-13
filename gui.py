from PyQt5.QtWidgets import (QWidget, QHBoxLayout,
                             QLabel, QApplication, QPushButton, QFileDialog)
from PyQt5.QtGui import QPixmap
import sys


class Example(QWidget):

    def __init__(self):
        super().__init__()

        self.lbl1 = QLabel(self)
        self.lbl4 = QLabel(self)
        self.init_ui()

    def init_ui(self):
        hbox = QHBoxLayout(self)

        pic_origin = QPixmap('./ui/open_image.png')

        self.lbl1.setPixmap(pic_origin)
        lbl2 = QLabel(self)
        lbl2.setPixmap(pic_origin)
        lbl3 = QLabel(self)
        lbl3.setPixmap(pic_origin)
        self.lbl4.setPixmap(pic_origin)

        btn1 = QPushButton("选择图片", self)
        btn1.clicked[bool].connect(self.open_image)
        btn2 = QPushButton("背景转换成红色", self)

        hbox.addWidget(self.lbl1)
        hbox.addWidget(lbl2)
        hbox.addWidget(lbl3)
        hbox.addWidget(self.lbl4)
        hbox.addWidget(btn1)
        hbox.addWidget(btn2)

        self.setLayout(hbox)
        self.move(300, 200)
        self.setWindowTitle('证件照人脸检测与背景替换')
        self.show()

    def open_image(self):
        img_name, img_type = QFileDialog.getOpenFileName(self,
                                                         "打开图片",
                                                         "",
                                                         " *.jpg;;*.png;;*.jpeg;;*.bmp;;All Files (*)")
        pic_origin = QPixmap(img_name)

        self.lbl1.setPixmap(pic_origin)


if __name__ == '__main__':

    app = QApplication(sys.argv)
    ex = Example()
    sys.exit(app.exec_())
