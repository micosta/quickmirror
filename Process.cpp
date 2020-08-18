/****************************************************************************
**
** Copyright (C) 2020 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt VS Tools.
**
** $QT_BEGIN_LICENSE:GPL-EXCEPT$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 as published by the Free Software
** Foundation with exceptions as appearing in the file LICENSE.GPL3-EXCEPT
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "Process.h"

#include <QDebug>

Process::Process(QObject* parent)
    : QProcess(parent)
{
    connect(
        this, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
        this, &Process::onFinished);
    connect(
        this, &QProcess::errorOccurred,
        this, &Process::onErrorOccurred);
}

Process::~Process()
{
}

void Process::setCommand(const QString& cmd)
{
    if (cmd != m_command) {
        m_command = cmd;
        emit commandChanged();
    }
}

QString Process::command() const
{
    return m_command;
}

void Process::start()
{
    if (state() == ProcessState::NotRunning)
        QProcess::start(m_command);
    else
        qInfo() << "==== QProcess: ERROR already running:" << m_command;
}

void Process::onFinished(int exitCode, QProcess::ExitStatus status)
{
    emit exit((status == ExitStatus::NormalExit) ? exitCode : -1, readAll());
}

void Process::onErrorOccurred(QProcess::ProcessError error)
{
    qInfo() << "==== QProcess: ERROR " << error;
}
